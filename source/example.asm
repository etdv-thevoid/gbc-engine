INCLUDE "includes/constants.inc"
INCLUDE "includes/macros.inc"
INCLUDE "includes/charmap.inc"

SECTION "Program Main Example", ROM0

/*
The main program loop.

`gbc-engine-core.inc` hands off code execution to a function labeled `_Main` when done with initial setup.

The function can assume the following:
- All ram areas are cleared
- LCD is off
- Interrupts are disabled
*/
_Main::
    ; Your code goes here!

    call _HelloWorld

    ; returning out of _Main will cause a crash!
    ret

ENDSECTION


SECTION "Font Tiles Example", ROM0

/*
`gbc-engine-core.inc` requires a .1bpp set of font tiles in ASCII format for the crash screen.

Format:

```
 !"#$%&'()*+,-./
0123456789:;<=>?
@ABCDEFGHIJKLMNO
PQRSTUVWXYZ[\]^_
`abcdefghijklmno
pqrstuvwxyz{|}~
```
*/
_FontTiles::
    INCBIN "assets/tilesets/font.1bpp"
.end::

ENDSECTION
