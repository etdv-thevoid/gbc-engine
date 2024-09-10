INCLUDE "includes/includes.inc"


SECTION "Tilemap Functions", ROM0

/*
Load tilemap into SCRN1.

Input:
- `a` = VRAM bank
- `hl` = Pointer to rle compressed tilemap data
*/
_LoadFontTilesSCRN1::
    ld de, vSCRN1
    jr _LoadTilemap

/*
Load tilemap into SCRN0.

Input:
- `a` = VRAM bank
- `hl` = Pointer to rle compressed tilemap data
*/
_LoadTilemapSCRN0::
    ld de, vSCRN0
    ; fallthrough


_LoadTilemap:
    push de
    push af

    ; Switch to buffer WRAM bank
    ld a, BANK("Tilemap Buffer")
    ldh [rSVBK], a

    ; Decompress tilemap to buffer
    ld de, wTilemapDecompressionBuffer
    call _MemCopyDecompressRLE

    ; Load tilemap to VRAM
    pop af
    pop de
    ld hl, wTilemapDecompressionBuffer
    jp _VideoMemCopy

ENDSECTION


SECTION "Tilemap Buffer", WRAMX, BANK[1]

; Buffer for decompressing rle compressed tilemap
wTilemapDecompressionBuffer:
    DS $1000

ENDSECTION
