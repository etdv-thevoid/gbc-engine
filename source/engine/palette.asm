INCLUDE "includes/includes.inc"


SECTION "Color Palette Functions", ROM0

/*
Increments and updates the current color palette
*/
_IncrementPalette::
    ld hl, wColorPaletteCurrent
    ld a, %0000_1111
    inc [hl]
    and a, [hl]
    ld [hl], a
    ; fallthrough

/*
Sets background palette 0
*/
_LoadPalette::
    call _IsGBColor
    jp z, _LoadPaletteMonochrome
    ; fallthrough

/*
Sets background palette 0 - Color
*/
_LoadPaletteColor:
    ld a, [wColorPaletteCurrent]
    ld hl, _PaletteColors
    ld b, NUMBER_OF_PALLETE_BYTES
    ld c, (NUMBER_OF_PALLETE_COLORS * 2)
    call _DataTable

    xor a
    jp _SetBackgroundPalette

/*
Sets background palette 0 - Monochrome
*/
_LoadPaletteMonochrome:
    ld a, [wColorPaletteCurrent]
    and a, TRUE
    jp nz, _SetDMGPalettesInverted
    jp _SetDMGPalettesDefault


/*
Simple palette colors
*/
_PaletteColors:
    INCLUDE "assets/palettes/default.pal"
    INCLUDE "assets/palettes/inverted.pal"
.end:

ENDSECTION


SECTION "Color Palette Variables", WRAM0

wColorPaletteCurrent:
    DB

ENDSECTION
