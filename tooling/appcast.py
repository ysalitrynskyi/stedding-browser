#!/usr/bin/env python3
"""Writes Stedding's update feeds: updates/appcast.xml for the Mac (ADR 0022) and
updates/appcast-windows.xml for Windows (ADR 0023, ADR 0026).

Sparkle reads the feed from the repository's main branch. tooling/publish-appcast
calls this with the release it adds; the newest item comes first and the older
ones follow, up to a few, so a Mac whose system the newest no longer supports
still finds the last one that runs there. The feed's own signature is added
afterwards by Sparkle's sign_update, over exactly the text written here.

Usage:
  appcast.py write --feed updates/appcast.xml --repo owner/name --version 0.2.0-beta.16 \
      --bundle-version 10020.16 --minimum-system 12.0 --length 185000000 \
      --signature <base64> --date "Fri, 16 Oct 2026 12:00:00 +0000"
      [--url http://127.0.0.1:8765/Stedding.dmg]   # the n-1 check's own server
  appcast.py write --platform windows --feed updates/appcast-windows.xml --repo owner/name \
      --version 0.2.0-beta.19 --bundle-version 156.2.0.19 --minimum-system 10.0 \
      --length 176000000 --signature <base64> --date "..."   # the Windows installer's item
      [--important "<reason>"]   # an important update (updates Up23, ADR 0031): Sparkle's
                                # criticalUpdate and the reason, one line of plain text
  appcast.py attach-signature --feed f --signature <base64>
      # appends the feed's own signature, over every byte written before it, as Sparkle's
      # sign_update does; the Windows browser checks it (updates Up15)
  appcast.py check --feed updates/appcast.xml   # parses it and lists the items
  appcast.py selftest
"""

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from xml.sax.saxutils import escape, quoteattr

SPARKLE = 'http://www.andymatuschak.org/xml-namespaces/sparkle'
# Stedding's own elements beside Sparkle's (ADR 0031): Sparkle ignores them.
STEDDING = 'https://stedding.dev/xml/appcast'
WINDOWS_OS = 'windows-x64'
SIGNATURE_MARK = '<!-- sparkle-signatures:'
KEEP = 5
VERSION_RE = re.compile(r'^\d+\.\d+\.\d+(-beta\.\d+)?$')


def _text(item, tag):
    node = item.find(tag)
    return node.text.strip() if node is not None and node.text else ''


def read_items(text):
    """The feed's items as dictionaries, newest first, as written."""
    root = ET.fromstring(text)
    channel = root.find('channel')
    items = []
    for item in channel.findall('item') if channel is not None else []:
        enclosure = item.find('enclosure')
        if enclosure is None:
            continue
        items.append({
            'title': _text(item, 'title'),
            'link': _text(item, 'link'),
            'date': _text(item, 'pubDate'),
            'version': _text(item, '{%s}shortVersionString' % SPARKLE),
            'bundle_version': _text(item, '{%s}version' % SPARKLE),
            'minimum_system': _text(item, '{%s}minimumSystemVersion' % SPARKLE),
            'os': enclosure.get('{%s}os' % SPARKLE, ''),
            'url': enclosure.get('url', ''),
            'length': enclosure.get('length', ''),
            'signature': enclosure.get('{%s}edSignature' % SPARKLE, ''),
            # updates Up23: kept when the feed is written again.
            'important': _text(item, '{%s}important' % STEDDING),
        })
    return items


def title_of(version):
    return 'Stedding ' + version.replace('-beta.', ' beta ')


def important_xml(item):
    """updates Up23: an important update, as Sparkle's critical one, with its reason."""
    if not item.get('important'):
        return []
    return [
        '      <sparkle:criticalUpdate></sparkle:criticalUpdate>',
        '      <stedding:important>%s</stedding:important>' % escape(item['important']),
    ]


def item_xml(item):
    if item.get('os') == WINDOWS_OS:
        return '\n'.join([
            '    <item>',
            '      <title>%s</title>' % escape(item['title']),
            '      <link>%s</link>' % escape(item['link']),
            '      <pubDate>%s</pubDate>' % escape(item['date']),
            '      <sparkle:version>%s</sparkle:version>'
            % escape(item['bundle_version']),
            '      <sparkle:shortVersionString>%s</sparkle:shortVersionString>'
            % escape(item['version']),
            '      <sparkle:minimumSystemVersion>%s</sparkle:minimumSystemVersion>'
            % escape(item['minimum_system']),
        ] + important_xml(item) + [
            '      <enclosure url=%s length=%s type="application/octet-stream" '
            'sparkle:os=%s sparkle:edSignature=%s/>' % (
                quoteattr(item['url']), quoteattr(item['length']),
                quoteattr(WINDOWS_OS), quoteattr(item['signature'])),
            '    </item>',
        ])
    return '\n'.join([
        '    <item>',
        '      <title>%s</title>' % escape(item['title']),
        '      <link>%s</link>' % escape(item['link']),
        '      <pubDate>%s</pubDate>' % escape(item['date']),
        '      <sparkle:version>%s</sparkle:version>' % escape(item['bundle_version']),
        '      <sparkle:shortVersionString>%s</sparkle:shortVersionString>'
        % escape(item['version']),
        '      <sparkle:minimumSystemVersion>%s</sparkle:minimumSystemVersion>'
        % escape(item['minimum_system']),
        '      <sparkle:hardwareRequirements>arm64</sparkle:hardwareRequirements>',
    ] + important_xml(item) + [
        '      <enclosure url=%s length=%s type="application/octet-stream" '
        'sparkle:edSignature=%s/>' % (quoteattr(item['url']),
                                      quoteattr(item['length']),
                                      quoteattr(item['signature'])),
        '    </item>',
    ])


def feed_xml(repo, items, platform='mac'):
    releases = 'https://github.com/%s/releases' % repo
    where = 'Windows' if platform == 'windows' else 'the Mac'
    head = [
        '<?xml version="1.0" encoding="utf-8"?>',
        '<rss version="2.0" xmlns:sparkle="%s" xmlns:stedding="%s">' % (SPARKLE,
                                                                        STEDDING),
        '  <channel>',
        '    <title>Stedding</title>',
        '    <link>%s</link>' % escape(releases),
        '    <description>New versions of Stedding for %s, from the '
        'project’s GitHub releases.</description>' % where,
        '    <language>en</language>',
    ]
    body = [item_xml(item) for item in items]
    return '\n'.join(head + body + ['  </channel>', '</rss>']) + '\n'


def new_item(args):
    windows = getattr(args, 'platform', 'mac') == 'windows'
    if not VERSION_RE.match(args.version):
        raise SystemExit('not a Stedding version: %s' % args.version)
    # The Mac's CFBundleVersion (updates Up11) or the Windows installer's four-part version
    # (updates Up14).
    shape = r'^\d+\.\d+\.\d+\.\d+$' if windows else r'^\d+\.\d+$'
    if not re.match(shape, args.bundle_version):
        raise SystemExit('not a bundle version: %s' % args.bundle_version)
    if not re.match(r'^\d+$', args.length):
        raise SystemExit('not a length: %s' % args.length)
    if not re.match(r'^[A-Za-z0-9+/]+={0,2}$', args.signature):
        raise SystemExit('not an EdDSA signature: %s' % args.signature)
    tag = 'v' + args.version
    important = (getattr(args, 'important', None) or '').strip()
    if important and (len(important) > 200 or '\n' in important or '<' in important):
        raise SystemExit('an important update\'s reason is one line of plain text, '
                         'at most 200 characters')
    if windows:
        return {
            'title': title_of(args.version),
            'link': 'https://github.com/%s/releases/tag/%s' % (args.repo, tag),
            'date': args.date,
            'version': args.version,
            'bundle_version': args.bundle_version,
            'minimum_system': getattr(args, 'minimum_system', None) or '10.0',
            'os': WINDOWS_OS,
            'url': getattr(args, 'url', None) or
            'https://github.com/%s/releases/download/%s/Stedding-%s-win-x64.exe'
            % (args.repo, tag, args.version),
            'length': args.length,
            'signature': args.signature,
            'important': important,
        }
    return {
        'title': title_of(args.version),
        'link': 'https://github.com/%s/releases/tag/%s' % (args.repo, tag),
        'date': args.date,
        'version': args.version,
        'bundle_version': args.bundle_version,
        'minimum_system': args.minimum_system,
        'url': getattr(args, 'url', None) or
        'https://github.com/%s/releases/download/%s/Stedding-%s-arm64.dmg'
        % (args.repo, tag, args.version),
        'length': args.length,
        'signature': args.signature,
        'os': '',
        'important': important,
    }


def unsigned(text):
    """The feed as written, without a signature comment a signing appended."""
    at = text.find(SIGNATURE_MARK)
    return text if at < 0 else text[:at]


def write(args):
    try:
        with open(args.feed, encoding='utf-8') as f:
            old = read_items(unsigned(f.read()))
    except FileNotFoundError:
        old = []
    item = new_item(args)
    kept = [o for o in old if o['version'] != item['version']]
    platform = getattr(args, 'platform', 'mac')
    with open(args.feed, 'w', encoding='utf-8', newline='\n') as f:
        f.write(feed_xml(args.repo, [item] + kept[:KEEP - 1], platform))


def attach_signature(args):
    """Sparkle's signed-feed form: the signature over every byte before it, and that
    length, in a comment at the end (updates Up15). The bytes signed are the file's as
    it is on disk when this runs, which is what the signature was made over."""
    if not re.match(r'^[A-Za-z0-9+/]+={0,2}$', args.signature):
        raise SystemExit('not an EdDSA signature: %s' % args.signature)
    with open(args.feed, 'rb') as f:
        data = f.read()
    if SIGNATURE_MARK.encode() in data:
        raise SystemExit('%s is signed already' % args.feed)
    with open(args.feed, 'ab') as f:
        f.write(('%s\nedSignature: %s\nlength: %d\n-->\n'
                 % (SIGNATURE_MARK, args.signature, len(data))).encode())


def check(args):
    with open(args.feed, encoding='utf-8') as f:
        items = read_items(f.read())
    for item in items:
        print('%s  %s  %s bytes' % (item['version'], item['bundle_version'],
                                    item['length']))
    return 0 if items else 1


def selftest():
    class A:
        pass
    a = A()
    a.repo, a.version, a.bundle_version = 'o/r', '0.2.0-beta.16', '10020.16'
    a.minimum_system, a.length, a.signature = '12.0', '123', 'abc+/='
    a.date = 'Fri, 16 Oct 2026 12:00:00 +0000'
    first = new_item(a)
    text = feed_xml('o/r', [first])
    items = read_items(text)
    assert items == [first], items
    a.version, a.bundle_version = '0.2.0-beta.17', '10020.17'
    second = new_item(a)
    items = read_items(feed_xml('o/r', [second] + items))
    assert [i['version'] for i in items] == ['0.2.0-beta.17', '0.2.0-beta.16']
    assert items[0]['url'].endswith('/v0.2.0-beta.17/Stedding-0.2.0-beta.17-arm64.dmg')
    assert title_of('0.2.0-beta.17') == 'Stedding 0.2.0 beta 17'
    for bad in ('0.2.0-rc.1', 'v0.2.0', '0.2'):
        a.version = bad
        try:
            new_item(a)
        except SystemExit:
            continue
        raise AssertionError('accepted ' + bad)
    # Windows items (updates Up14): their own version shape and enclosure.
    a.platform, a.version, a.bundle_version = 'windows', '0.2.0-beta.19', '156.2.0.19'
    win = new_item(a)
    text = feed_xml('o/r', [win], 'windows')
    items = read_items(text)
    assert items[0]['os'] == WINDOWS_OS and items[0]['bundle_version'] == '156.2.0.19', items
    assert items[0]['url'].endswith('/v0.2.0-beta.19/Stedding-0.2.0-beta.19-win-x64.exe')
    assert 'for Windows' in text
    a.bundle_version = '10020.19'
    try:
        new_item(a)
        raise AssertionError('a Mac bundle version passed for Windows')
    except SystemExit:
        pass
    signed = text + SIGNATURE_MARK + '\nedSignature: abc=\nlength: %d\n-->\n' % len(text.encode())
    assert unsigned(signed) == text
    assert read_items(signed)[0]['version'] == '0.2.0-beta.19'
    # updates Up23: an important item carries Sparkle's criticalUpdate and its reason,
    # and both survive the next release's rewrite.
    a.platform, a.version, a.bundle_version = 'mac', '0.4.0-beta.9', '10040.9'
    a.important = 'Fixes a security hole in the PDF viewer'
    urgent = new_item(a)
    text = feed_xml('o/r', [urgent])
    assert '<sparkle:criticalUpdate></sparkle:criticalUpdate>' in text, text
    assert read_items(text)[0]['important'] == a.important
    a.version, a.bundle_version, a.important = '0.4.0-beta.10', '10040.10', None
    later = new_item(a)
    items = read_items(feed_xml('o/r', [later] + read_items(text)))
    assert items[0]['important'] == '' and items[1]['important'] == urgent['important']
    a.important = 'two\nlines'
    try:
        new_item(a)
        raise AssertionError('a reason of two lines passed')
    except SystemExit:
        pass
    print('appcast.py: ok')
    return 0


def main(argv):
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    w = sub.add_parser('write')
    for name in ('feed', 'repo', 'version', 'bundle-version', 'minimum-system',
                 'length', 'signature', 'date'):
        w.add_argument('--' + name, required=True)
    # The n-1 check's local feed serves the image itself (docs/HANDOFF.md,
    # "The updater"); a release's comes from the release.
    w.add_argument('--url')
    w.add_argument('--platform', choices=('mac', 'windows'), default='mac')
    # updates Up23 (ADR 0031): an important update, with its reason.
    w.add_argument('--important')
    s = sub.add_parser('attach-signature')
    s.add_argument('--feed', required=True)
    s.add_argument('--signature', required=True)
    c = sub.add_parser('check')
    c.add_argument('--feed', required=True)
    sub.add_parser('selftest')
    args = parser.parse_args(argv)
    if args.command == 'write':
        write(args)
        return 0
    if args.command == 'check':
        return check(args)
    if args.command == 'attach-signature':
        attach_signature(args)
        return 0
    return selftest()


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
