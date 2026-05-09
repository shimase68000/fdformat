# Rationale — FDFORMAT Design Notes

## Motivation

Preparing large numbers of floppy disks was a repetitive and time-consuming task.

Formatting them one by one — inserting a disk, launching the formatter, confirming the operation,\
waiting for completion, ejecting, then repeating — was tedious enough to be a real obstacle\
when dozens of disks needed to be prepared in sequence.

FDFORMAT was not made with any intention of public release.\
It was built purely as a personal tool, designed around a single question:

> What would the ideal floppy disk formatter look like for my own use?

The answer was a tool that demanded as little attention as possible.

---

## Design Approach

The core design was straightforward:

> The user should do nothing except insert and remove disks.

To achieve this, the tool handled everything automatically:

- Continuously monitor multiple drives for inserted disks
- Begin formatting immediately upon detection
- Eject the disk automatically when formatting is complete
- Return to monitoring, ready for the next disk

No confirmation prompts. No manual steps between disks.

The result behaved less like a utility and more like an appliance.\
A disk inserted into a drive would be formatted and returned automatically —\
much like bread placed into a toaster.

---

## Multiple Drive Support

The X68000 supported up to four floppy disk drives simultaneously:\
two built-in and up to two external units.

FDFORMAT monitored all available drives in parallel,\
checking each in turn during every pass of the main loop.\
Multiple disks could be in progress at the same time,\
which further reduced total processing time when several drives were connected.

---

## Slide Format

Standard floppy disk formatters wrote sectors starting from a fixed position on each track.

FDFORMAT used a different approach: sector start positions are staggered across tracks\
to improve sequential read/write performance.

When the drive head moves from one track to the next, a small amount of time is consumed\
by the physical movement. If the next track also starts at sector 1,\
the disk will have already rotated past that sector by the time the head settles —\
requiring a full additional rotation before reading can begin.

By offsetting the sector start position on each track to compensate for this delay,\
the drive can begin reading immediately upon arrival.

In the implementation, two bytes immediately before the sector ID buffer\
hold the accumulated slide value and the current start sector.\
After formatting each side-1 track, these are updated by addition,\
and the resulting start sector wraps cyclically through sectors 1 to 8.\
This produces staggered layouts across successive tracks without requiring\
any external configuration.

---

## Realising the Risk

When development began, the focus was entirely on usability.\
The goal was a formatter that worked continuously with minimal effort from the user.\
The absence of a confirmation step was seen as a feature — and it was.

It was only during development that the implication became clear.

A conventional formatter requires explicit confirmation before any destructive operation begins.\
This is not formality. It is a safety mechanism — one that protects the user\
from the consequences of an absent-minded action.

FDFORMAT had no such mechanism.\
Any disk inserted into a monitored drive would be formatted immediately,\
with no opportunity to intervene.

For a user who knew the tool was running, this was exactly the intended behaviour.\
For anyone else — or for the same user on a different day, out of habit —\
it would silently destroy the contents of whatever disk happened to be inserted.

Once this was clear, the decision not to release the tool followed naturally.\
The very quality that made it effective for personal use made it unsuitable for anyone else.

---

## Why It Is Published Now

FDFORMAT is published here not as a usable tool, but as a technical record.

The source code documents a particular approach to automation and disk formatting\
on the X68000: parallel drive monitoring, immediate formatting on disk detection,\
automatic ejection, and slide format sector layout.

The design decisions — including the deliberate absence of a confirmation step,\
and the reasoning behind that decision — are part of that record.

The original executable is included for reference.\
The source is preserved as-is.
