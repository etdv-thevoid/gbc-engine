INCLUDE "includes/includes.inc"

SECTION "Hello World", ROM0

/*
Hello World!

Example routine demonstrating a small portion of `gbc-engine`'s functionality.
*/
_HelloWorld::

    ; Load font tiles
    xor a
    ld hl, _FontTiles
    ld bc, (_FontTiles.end - _FontTiles)
    ld de, vBLK21.32
    call _VideoMemCopy1BitPerPixel

    ; Load Hello World tiles
    xor a
    ld hl, _HelloWorldTiles
    ld bc, (_HelloWorldTiles.end - _HelloWorldTiles)
    ld de, vBLK21.128
    call _VideoMemCopy

    ; Decompress Hello World tilemap
    ld hl, _HelloWorldTilemap
    ld de, wTilemapDecompressionBuffer
    call _MemCopyDecompressRLE

    ; Load Hello World tilemap
    xor a
    ld hl, wTilemapDecompressionBuffer
    ld de, vSCRN0
    call _VideoMemCopy
    
    ; Set VBlank Interrupt Handler function
    ld bc, _ScanKeys
    rst _SetVBLHandler

    ; Set Timer Interrupt Handler function
    ld bc, _UpdateSound
    rst _SetTIMHandler

    ; Initialize Sound driver with 4 sounds
    ld a, 4
    ld bc, _HelloWorldSounds
    call _InitSound

    ; Enable VBlank Interrupt
    ; (enabling the Timer Interrupt is handled by the sound driver)
    ld a, IEF_VBLANK
    ldh [rIE], a

    ; Set Background Color (if playing on GBC)
    call _HelloWorldSetBackgroundColor

    ; Turn on LCD
    ld a, LCDCF_ON | LCDCF_BGON
    ldh [rLCDC], a

    ; During the first (blank) frame, initialize palette
    call _SetDMGPalettesDefault
    
    ; Enable Interrupts
    ei

    ; Play sound 0 (coin collect sfx)
    ld a, 0
    call _PlaySound

.loop:
    ; Wait for VBlank Interrupt (which polls keys and updates HRAM variables)
    call _WaitForVBLInterrupt

    ; Force a crash if Start or Select were pressed
    ldh a, [hKeysPressed]
    and a, PADF_START | PADF_SELECT
    jr nz, .crash

    ; Invert palettes if B or A were pressed
    ldh a, [hKeysPressed]
    and a, PADF_B | PADF_A
    jr nz, .invert

    ; Play percussion sound effect if D-Pad was pressed
    ldh a, [hKeysPressed]
    and a, PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT
    jr nz, .percussion

    jr .loop

.crash:
    ; Play sound 1 (game over sfx)...
    ld a, 1
    call _PlaySound

    call _WaitSound

    ; and return back to main, causing a crash
    ret

.invert:
    ; Invert background palette...
    ldh a, [rBGP]
    cp a, %11100100
    call z, _SetDMGPalettesInverted
    call nz, _SetDMGPalettesDefault

    ; and play sound 2 (jump sfx)
    ld a, 2
    call _PlaySound

    ; Cycle colors on GBC instead!
    call _HelloWorldIncrementBackgroundColor

    jr .loop

.percussion:
    ; and play sound 3 (percussion)
    ld a, 3
    call _PlaySound

    jr .loop


; Hello World tiles
_HelloWorldTiles:
    INCBIN "assets/tilesets/hello_world.2bpp"
.end:


; Hello World tilemap
_HelloWorldTilemap:
    INCBIN "assets/tilemaps/hello_world_tilemap.rle"
.end:


_HelloWorldIncrementBackgroundColor:
    ld hl, wColorPalette
    ld a, [hl]
    inc a
    and a, OAMF_PALMASK
    ld [hl], a
    ; fallthrough

_HelloWorldSetBackgroundColor:
    call _IsGBColor
    ret z

    ld a, [wColorPalette]
    ld hl, _HelloWorldPalettes
    ld b, 8                     ; each palette is 8 bytes wide (2 per color)
    ld c, 32                    ; x 8 palettes = 32 bytes in the table
    call _DataTable

    xor a
    jp _SetBackgroundPalette


; Hello World GBC Palettes
_HelloWorldPalettes:
    rgb_palette #000000, #555555, #AAAAAA, #FFFFFF
    rgb_palette #000000, #550000, #AA0000, #FF0000
    rgb_palette #000000, #005500, #00AA00, #00FF00
    rgb_palette #000000, #000055, #0000AA, #0000FF
    rgb_palette #000000, #555500, #AAAA00, #FFFF00
    rgb_palette #000000, #542A00, #AA5500, #FF8000
    rgb_palette #000000, #005555, #00AAAA, #00FFFF
    rgb_palette #000000, #550055, #AA00AA, #FF00FF


; Hello World sounds
_HelloWorldSounds:
    DW _SfxCoinCollect
    DW _SfxGameOver
    DW _SfxJump
    DW _SfxPercussion
    DW _NULL


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


SECTION "Hello World Variables", WRAM0

wColorPalette:
    DB

ENDSECTION


SECTION "Tilemap Decompression Buffer", WRAMX[_RAMBANK], BANK[1]

wTilemapDecompressionBuffer:
    DS $1000

ENDSECTION
