INCLUDE "includes/includes.inc"


SECTION "Color Palette Functions", ROM0

/*
Increments and updates the current color palette
*/
_IncrementPalette::
    ld hl, wColorPaletteCurrent
    ld a, OAMF_PALMASK
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
    ld hl, _DefaultPaletteColors
    ld b, NUMBER_OF_PALLETE_BYTES
    ld c, NUMBER_OF_PALLETE_COLORS
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
Simple default palette colors

- Greyscale
- Red
- Blue
- Green
- Yellow
- Orange
- Cyan
- Magenta
*/
_DefaultPaletteColors:
    INCLUDE "assets/palettes/default.pal"
.end:

ENDSECTION


SECTION "Color Palette Variables", WRAM0

wColorPaletteCurrent:
    DB

ENDSECTION
