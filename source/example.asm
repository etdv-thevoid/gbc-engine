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
    INCBIN "temp/font.1bpp"
.end::

ENDSECTION


SECTION "Sound Data Example", ROM0

/*
`gbc-engine-core.inc` requires a lookup table of addresses to sound data to play sounds!

```
_SoundDataTable:
    DW _SfxExample1
    DW _SfxExample2
    DW _SfxExample3
    DW _SfxExample4
    DW $0000
```
*/
_SoundDataTable::
    DW _SfxCoinCollect
    DW _SfxGameOver
    DW _SfxJump
    DW _SfxPercussion
    DW $0000

; Simple coin collect sound effect
_SfxCoinCollect:
    sound_entry_start 1, 2
    sound_entry_ch1  5, 0,0,0, 2,42, 15,0,0, 0, 1915
    sound_entry_ch1 15, 0,0,0, 2, 4, 15,0,0, 0, 1949
    sound_entry_stop

; Simple Game Over sound effect
_SfxGameOver:
    sound_entry_start 2, 3
    sound_entry_ch2 3, 2,51, 15,0,0, 0, 31
    sound_entry_ch2 2, 2,55, 7,0,0,  0, 31
    sound_entry_ch2 5, 2,42, 15,0,0, 0, 31
    sound_entry_stop

; Simple jump sound effect
_SfxJump:
    sound_entry_start 3, 1
    sound_entry_ch3 3, 0, 3, 1, 1924
    sound_entry_stop

; Simple percussion sound effect
_SfxPercussion:
    sound_entry_start 4, 1
    sound_entry_ch4 5, 0, 7,0,0, 5,1,7, 0
    sound_entry_stop

ENDSECTION
