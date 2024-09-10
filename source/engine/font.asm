INCLUDE "includes/includes.inc"


SECTION "Font Tiles Functions", ROM0

/*
`gbc-engine-core.inc` requires a .1bpp set of font
tiles in ASCII format for the crash screen.

The CC0 bitmap font `Public Pixel` has been included
as an example. But feel free to replace it with any
font you wish!

ASCII Format:

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

/*
Load font tiles into VRAM tile block 0.
*/
_LoadFontTilesBLK0::
    ld de, vBLK01.32
    jr _LoadFontTiles

/*
Load font tiles into VRAM tile block 1.

**Note:**
Using this function requires a custom charmap!
*/
_LoadFontTilesBLK1::
    ld de, vBLK01.160
    jr _LoadFontTiles

/*
Load font tiles into VRAM tile block 2.
*/
_LoadFontTilesBLK2::
    ld de, vBLK21.32
    ; fallthrough


_LoadFontTiles:
    xor a
    ld hl, _FontTiles
    ld bc, (_FontTiles.end - _FontTiles)
    jp _VideoMemCopy1BitPerPixel

ENDSECTION
