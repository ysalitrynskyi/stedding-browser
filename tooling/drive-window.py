#!/usr/bin/env python3
"""Drive the live Stedding window with synthetic input; used by tooling/drive.

Usage: drive-window.py <steps-file>. Coordinates are window points; the window
is found by owner name and never raised. See tooling/drive for the step grammar."""
#   click X Y | rclick X Y | dblclick X Y | hover X Y | drag X1 Y1 X2 Y2
#   dragstart X Y | dragmove X Y | dragend      a drag in steps, so a shot can land mid-drag
#   key <name>[+cmd][+shift]   (names: t, l, w, enter, esc, tab, left, right, up, down, a-z, 0-9)
#   type <text> | wait <sec> | shot <file.png> | activate
import sys, time, subprocess, Quartz
OWNER="Stedding"
import os
CAP=os.path.join(os.path.dirname(os.path.abspath(__file__)), "capture-window.py")
def origin():
    best=None; area=0
    for w in Quartz.CGWindowListCopyWindowInfo(Quartz.kCGWindowListOptionAll, Quartz.kCGNullWindowID):
        if OWNER.lower() not in w.get("kCGWindowOwnerName","").lower(): continue
        b=w.get("kCGWindowBounds",{}); a=b.get("Width",0)*b.get("Height",0)
        if a>area and a>100000: best=b; area=a
    return best["X"], best["Y"]
def mouse(kind, x, y, button=Quartz.kCGMouseButtonLeft, clicks=1):
    e=Quartz.CGEventCreateMouseEvent(None, kind, (x,y), button)
    # A created mouse event inherits the last chord's modifiers too (trap 3
    # in docs/HANDOFF.md): after Ctrl-Cmd-F a plain click became Ctrl-click,
    # which macOS treats as a right-click.
    Quartz.CGEventSetFlags(e, 0)  # mouse
    Quartz.CGEventSetIntegerValueField(e, Quartz.kCGMouseEventClickState, clicks)
    Quartz.CGEventPost(Quartz.kCGHIDEventTap, e)
KEYS={'a':0,'s':1,'d':2,'f':3,'h':4,'g':5,'z':6,'x':7,'c':8,'v':9,'b':11,'q':12,'w':13,'e':14,'r':15,'y':16,'t':17,
 '1':18,'2':19,'3':20,'4':21,'6':22,'5':23,'9':25,'7':26,'8':28,'0':29,'o':31,'u':32,'i':34,'p':35,'l':37,'j':38,'k':40,
 'n':45,'m':46,'enter':36,'tab':48,'space':49,'esc':53,'left':123,'right':124,'down':125,'up':126,'backspace':51,
 'delete':117,'home':115,'end':119,'pageup':116,'pagedown':121}
def key(spec):
    parts=spec.split('+'); name=parts[0]; mods=parts[1:]
    flags=0
    if 'cmd' in mods: flags|=Quartz.kCGEventFlagMaskCommand
    if 'shift' in mods: flags|=Quartz.kCGEventFlagMaskShift
    if 'ctrl' in mods: flags|=Quartz.kCGEventFlagMaskControl
    if 'alt' in mods: flags|=Quartz.kCGEventFlagMaskAlternate
    code=KEYS[name]
    for down in (True, False):
        e=Quartz.CGEventCreateKeyboardEvent(None, code, down)
        Quartz.CGEventSetFlags(e, flags)
        Quartz.CGEventPost(Quartz.kCGHIDEventTap, e); time.sleep(0.05)
PUNCT={'.':47,'/':44,'-':27,' ':49}
def type_text(text):
    # Real key codes where we have them (Chromium keys off the virtual code), the
    # unicode-string path only for characters outside the table.
    for ch in text:
        code=KEYS.get(ch.lower(), PUNCT.get(ch))
        for down in (True, False):
            if code is not None:
                e=Quartz.CGEventCreateKeyboardEvent(None, code, down)
                # Explicit flags every time: a created event otherwise inherits the
                # modifier state left behind by the last chord (Cmd stuck after Cmd+T).
                Quartz.CGEventSetFlags(e, Quartz.kCGEventFlagMaskShift if ch.isupper() else 0)
            else:
                e=Quartz.CGEventCreateKeyboardEvent(None, 0, down)
                Quartz.CGEventSetFlags(e, 0)
                Quartz.CGEventKeyboardSetUnicodeString(e, len(ch), ch)
            Quartz.CGEventPost(Quartz.kCGHIDEventTap, e); time.sleep(0.03)

def to_screen(x,y):
    ox,oy=origin(); return float(x)+ox, float(y)+oy
def click(x,y,button=Quartz.kCGMouseButtonLeft,clicks=1):
    sx,sy=to_screen(x,y)
    down=Quartz.kCGEventLeftMouseDown if button==Quartz.kCGMouseButtonLeft else Quartz.kCGEventRightMouseDown
    up=Quartz.kCGEventLeftMouseUp if button==Quartz.kCGMouseButtonLeft else Quartz.kCGEventRightMouseUp
    mouse(Quartz.kCGEventMouseMoved,sx,sy); time.sleep(0.2)
    for i in range(clicks):
        mouse(down,sx,sy,button,i+1); time.sleep(0.08); mouse(up,sx,sy,button,i+1); time.sleep(0.12)
def drag_start(x,y):
    sx,sy=to_screen(x,y)
    mouse(Quartz.kCGEventMouseMoved,sx,sy); time.sleep(0.3)
    mouse(Quartz.kCGEventLeftMouseDown,sx,sy); time.sleep(0.3)
    for dx,dy in ((1,1),(2,3),(3,6),(4,9)):
        mouse(Quartz.kCGEventLeftMouseDragged,sx+dx,sy+dy); time.sleep(0.1)
    drag_start.at=(sx+4,sy+9)
def drag_move(x,y):
    sx1,sy1=drag_start.at; sx2,sy2=to_screen(x,y)
    for i in range(1,31):
        t=i/30; mouse(Quartz.kCGEventLeftMouseDragged,sx1+(sx2-sx1)*t,sy1+(sy2-sy1)*t); time.sleep(0.05)
    drag_start.at=(sx2,sy2); time.sleep(0.5)
def drag_end():
    sx,sy=drag_start.at; mouse(Quartz.kCGEventLeftMouseUp,sx,sy)
def drag(x1,y1,x2,y2):
    sx1,sy1=to_screen(x1,y1); sx2,sy2=to_screen(x2,y2)
    mouse(Quartz.kCGEventMouseMoved,sx1,sy1); time.sleep(0.3)
    mouse(Quartz.kCGEventLeftMouseDown,sx1,sy1); time.sleep(0.3)
    for dx,dy in ((1,1),(2,3),(3,6),(4,9)):
        mouse(Quartz.kCGEventLeftMouseDragged,sx1+dx,sy1+(dy if sy2>sy1 else -dy)); time.sleep(0.1)
    for i in range(1,41):
        t=i/40; mouse(Quartz.kCGEventLeftMouseDragged,sx1+(sx2-sx1)*t,sy1+(sy2-sy1)*t); time.sleep(0.06)
    time.sleep(0.8); mouse(Quartz.kCGEventLeftMouseUp,sx2,sy2)
for raw in open(sys.argv[1]):
    line=raw.strip()
    if not line or line.startswith('#'): continue
    op,*args=line.split(' ',1); arg=args[0] if args else ''
    a=arg.split()
    if op=='click': click(a[0],a[1])
    elif op=='rclick': click(a[0],a[1],Quartz.kCGMouseButtonRight)
    elif op=='dblclick': click(a[0],a[1],clicks=2)
    elif op=='hover': sx,sy=to_screen(a[0],a[1]); mouse(Quartz.kCGEventMouseMoved,sx,sy)
    elif op=='drag': drag(*a[:4])
    elif op=='dragstart': drag_start(a[0],a[1])
    elif op=='dragmove': drag_move(a[0],a[1])
    elif op=='dragend': drag_end()
    elif op=='key': key(arg)
    elif op=='type': type_text(arg)
    elif op=='wait': time.sleep(float(arg))
    elif op=='shot': time.sleep(0.6); subprocess.run(['python3',CAP,OWNER,arg],check=False)
    elif op=='activate':
        subprocess.run(['osascript','-e','tell application "System Events" to set frontmost of (first process whose name contains "Stedding") to true'],check=False); time.sleep(1.2)
    else: print("unknown op", op)
    print("ok", line, flush=True)
