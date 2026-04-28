# FDFORMAT

FD formatter for X68000, preserved as original implementation.

---

## Overview

FDFORMAT is an automated floppy disk formatter for the X68000.

It was created as a personal utility for formatting many floppy disks efficiently.\
Rather than manually formatting disks one by one, this tool turns the X68000 into a dedicated floppy disk formatting machine.\
The tool minimizes user interaction — disks are formatted and ejected automatically, allowing continuous batch processing.\

The original source code is preserved here as-is.

---

## Features

* Supports up to 4 floppy disk drives\
  (2 built-in drives + up to 2 external drives)

* Automatically detects inserted disks

* Automatically starts formatting when a disk is inserted

* Automatically ejects the disk after formatting is complete

* Displays formatting progress by track

* Includes slide-format style sector rotation handling\
  (adjusts sector start positions to improve read/write performance)

---

## Typical Usage

1. Launch `FDFORMAT`
2. Insert floppy disks into available drives
3. Formatting begins automatically
4. When complete, disks are ejected
5. Insert the next disks and continue
6. To exit, press the `ESC` key

This workflow was useful when preparing many disks in sequence.

In practice, it behaved **like a toaster for floppy disks**:\
insert a disk, wait briefly, and receive it automatically when formatted.

---

## Background

This tool was originally made for personal use and was not publicly released at the time.

Although compact in size, it was practical and efficient.\
For bulk floppy disk preparation, it made the X68000 function like a dedicated formatting station.

The design goal was simplicity:

* no unnecessary steps
* minimal waiting time
* clear completion feedback

Just insert disks casually and keep working.

---

## Technical Notes

The program uses Human68k DOS / IOCS calls to:

* detect drive media state
* perform formatting
* control disk ejection
* update progress display

It continuously monitors multiple drives and processes disks as they are inserted.

The source remains close to the original implementation.

---

## Notes

* Intended for X68000 systems with floppy disk drives
* Behavior may depend on drive configuration
* Preserved for historical and technical interest

---

## Status

This repository preserves the original implementation.

The source code is provided as-is,\
with minimal modification.

---

## License

MIT License
