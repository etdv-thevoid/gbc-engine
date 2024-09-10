INCLUDE "includes/includes.inc"


SECTION "Hello World State Functions", ROMX

/*
Hello World!

Example state demonstrating a small portion of `gbc-engine`'s functionality.
*/
xHelloWorld::
    ; Load graphics
    call xLoadHelloWorldGraphics

    ; Turn on LCD
    ld a, LCDCF_ON | LCDCF_BGON
    ldh [rLCDC], a

    ; Play coin sfx
    ld a, SOUND_EFFECT_COIN
    call _PlaySound

    ; fallthrough


xHelloWorldLoop:
    ; Wait for VBlank Interrupt
    call _WaitForVBLInterrupt

    ; Force a forceCrash if Start or Select were pressed
    ldh a, [hKeysPressed]
    and a, PADF_START | PADF_SELECT
    jr nz, .forceCrash

    ; Invert palettes if B or A were pressed
    ldh a, [hKeysPressed]
    and a, PADF_B | PADF_A
    jr nz, .changeColorPalette

    ; Play playPercussionSFX sound effect if D-Pad was pressed
    ldh a, [hKeysPressed]
    and a, PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT
    jr nz, .playPercussionSFX

    jr xHelloWorldLoop

.forceCrash:
    ; Play game over sfx...
    ld a, SOUND_EFFECT_GAME_OVER
    call _PlaySound

    ; Wait for all sounds to finish playing
    call _WaitSound

    ; Force a crash by incrementing main state past the limit of 1
    jp _MainStateIncrement

.changeColorPalette:
    ; Increment the current color palette
    call _IncrementPalette

    ; and play jump sfx
    ld a, SOUND_EFFECT_JUMP
    call _PlaySound

    jr xHelloWorldLoop

.playPercussionSFX:
    ; and play percussion SFX
    ld a, SOUND_EFFECT_PERCUSSION
    call _PlaySound

    jr xHelloWorldLoop

/*
Load Hello World Tiles and Tilemap to VRAM
*/
xLoadHelloWorldGraphics:
    ; Load tiles to VRAM
    xor a
    ld hl, xHelloWorldTiles
    ld bc, (xHelloWorldTiles.end - xHelloWorldTiles)
    ld de, vBLK21.128
    call _VideoMemCopy

    ; Load tilemap to VRAM
    xor a
    ld hl, xHelloWorldTilemap
    jp _LoadTilemapSCRN0


; Hello World 2bpp tiles
xHelloWorldTiles:
    INCBIN "assets/tilesets/hello_world.2bpp"
.end:


; Hello World rle compressed tilemap
xHelloWorldTilemap:
    INCBIN "assets/tilemaps/hello_world_tilemap.rle"
.end:

ENDSECTION
