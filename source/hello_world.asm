INCLUDE "includes/constants.inc"
INCLUDE "includes/macros.inc"
INCLUDE "includes/charmap.inc"

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
    call _VideoMemCopyMonochrome

    ; Load Hello World tiles
    xor a
    ld hl, _HelloWorldTiles
    ld bc, (_HelloWorldTiles.end - _HelloWorldTiles)
    ld de, vBLK21.128
    call _VideoMemCopy

    ; Load Hello World tilemap
    xor a
    ld hl, _HelloWorldTilemap
    ld bc, (_HelloWorldTilemap.end - _HelloWorldTilemap)
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
    cpl
    ldh [rBGP], a

    ; and play sound 2 (jump sfx)
    ld a, 2
    call _PlaySound

    jr .loop

.percussion:
    ; and play sound 3 (percussion)
    ld a, 3
    call _PlaySound

    jr .loop


; Hello World tiles
_HelloWorldTiles:
    INCBIN "temp/hello_world.2bpp"
.end:


; Hello World tilemap
_HelloWorldTilemap:
    INCBIN "assets/hello_world.tilemap"
.end:


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
