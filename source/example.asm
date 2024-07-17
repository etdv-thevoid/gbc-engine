INCLUDE "includes/constants.inc"
INCLUDE "includes/macros.inc"
;INCLUDE "includes/charmap.inc"

SECTION "Example Code", ROMX

xExample::
    ld hl, vBLK21
    ld bc, (vBLK21.end - vBLK21)
    call _VideoMemSetRandom

    ld hl, vSCRN0
    ld bc, (vSCRN0.end - vSCRN0)
    call _VideoMemSetRandom

    ld hl, sBGP
    ld bc, $0003
    ld de, wBGP
    call _LoadFromSRAM

    ld a, [wBGP]
    and a, a
    jr nz, .continue
    ld a, %11100100
    ld [wBGP], a
    cpl 
    ld [wOPB0], a
    ld [wOPB1], a

    ldh a, [hIsGBColorFlag]
    and a, a
    jr z, .continue
    
    ld hl, xBGPals
    call _SetBackgroundPaletteAll

    ld hl, xOBPals
    call _SetSpritePaletteAll

.continue
    ; Initialize VBlank Handler
    ld bc, xExampleVBLHandler
    rst _SetVBLHandler

    ; Turn on LCD
    ld a, LCDCF_ON | LCDCF_BGON
	ldh [rLCDC], a

	; During the first (blank) frame, initialize display registers
	ld a, [wBGP]
	ldh [rBGP], a
	ld a, [wOPB0]
    ldh [rOBP0], a
	ld a, [wOPB1]
    ldh [rOBP1], a

    ld a, IEF_VBLANK
    ldh [rIE], a

.loop:
    ei

    call _WaitForVBLInterrupt

    di

    ldh a, [hKeysPressed]
    and a, PADF_B | PADF_A
    jr z, .loop

    ld hl, wBGP
    ld bc, $0003
    ld de, sBGP
    call _SaveToSRAM

    jr .loop

xExampleVBLHandler::
    call _ScanKeys
    ldh a, [hKeysPressed]
    and a, PADF_B | PADF_A
    ret z

    ; Invert screen colors with A or B
    ldh a, [rBGP]
    cpl
    ldh [rBGP], a
    ld [wBGP], a

    ldh a, [rOBP0]
    cpl
    ldh [rOBP0], a
    ld [wOPB0], a

    ldh a, [rOBP1]
    cpl
    ldh [rOBP1], a
    ld [wOPB1], a

    ret

xBGPals:
    rgb_palette #FFFFFF, #AAAAAA, #555555, #000000
    rgb_palette #FF0000, #AA0000, #550000, #000000
    rgb_palette #00FF00, #00AA00, #005500, #000000
    rgb_palette #0000FF, #0000AA, #000055, #000000
    rgb_palette #FF0000, #AA0000, #550000, #000000
    rgb_palette #00FF00, #00AA00, #005500, #000000
    rgb_palette #0000FF, #0000AA, #000055, #000000
    rgb_palette #FFFFFF, #AAAAAA, #555555, #000000
.end:

xOBPals:
    rgb_palette #FFF, #AAA, #555, #000
    rgb_palette #F00, #A00, #500, #000
    rgb_palette #0F0, #0A0, #050, #000
    rgb_palette #00F, #00A, #005, #000
    rgb_palette #F00, #A00, #500, #000
    rgb_palette #0F0, #0A0, #050, #000
    rgb_palette #00F, #00A, #005, #000
    rgb_palette #FFF, #AAA, #555, #000
.end:

SECTION "Example WRAM", WRAM0

wBGP:
    DS 1
wOPB0:
    DS 1
wOPB1:
    DS 1

wPAL:
    DS 64


SECTION "Example SRAM", SRAM

sBGP:
    DS 1
sOPB0:
    DS 1
sOPB1:
    DS 1

sPAL:
    DS 64
