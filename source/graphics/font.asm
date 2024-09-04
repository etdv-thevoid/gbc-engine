INCLUDE "includes/includes.inc"

SECTION "Font Tiles", ROM0

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
