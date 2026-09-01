# patches/

The Stedding patch series: ordered, numbered patches applied on top of the pinned
Chromium version in `../tooling/chromium-version`.

The series is organised **by feature, not by date**. A fix to Spaces amends the Spaces
patch it belongs to (`git commit --fixup=<sha>` in the checkout, then `git rebase
--autosquash`); it does not become patch 0044 at the end. A series that records every
toolbar-height change as its own patch is a changelog, and a changelog is what makes
the next Chromium rebase expensive. Squashing the current series is `S-11` in
`../BACKLOG.md`.

Most branding is **not** here: it is asset replacement in [../branding/](../branding/),
which costs no patches at all. A patch is the last resort, not the first.

## Rules

Enforced by `tooling/check-repo patches`, which CI runs:

- **Filename**: `NNNN-short-slug.patch`, four digits, lowercase and hyphenated.
- **Numbering**: contiguous from `0001`. Renumbering is fine; gaps are not.
- **Header**: every patch carries `Subject:`, `Why:` and `Removable when:`.

`Why:` is the reason the patch exists at all. `Removable when:` is the condition that
would let us delete it — an upstream flag landing, a feature being redesigned, a
dependency going away. A patch nobody can justify or delete is how a minimal patch set
stops being minimal.

Which upstream files a patch touches is answered by the diffstat `git format-patch`
writes under the message, so it is not restated by hand where it could drift.

## Do not edit these files

The patches are generated, not authored. The working representation is commits on the
`stedding-work` branch in the Chromium checkout:

```bash
tooling/apply-patches      # series -> commits
# edit, commit, reorder, rebase
tooling/update-patches     # commits -> series
```

Editing a `.patch` by hand puts it out of step with the branch, and the next
`update-patches` will silently overwrite your change. `apply-patches` also refuses to
rebuild a branch holding commits the series does not account for, so exporting before
re-applying is not optional.
