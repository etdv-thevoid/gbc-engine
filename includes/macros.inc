INCLUDE "libraries/rgbds-structs/structs.inc"
    rgbds_structs_version 4.0.0


; GBC palette entry using html rgb color codes
;
; Usage:
; - `rgb_palette #FFFFFF, #AAAAAA, #555555, #000000`
;
; Outputs:
; - `DW $7FFF, $5294, $294A, $0000`
MACRO rgb_palette
    ASSERT (_NARG == 4), "rgb_palette requires 4 color codes and parsed {_NARG}."

    REPT _NARG
        rgb_color \1
        SHIFT 1
    ENDR
ENDM

; GBC color entry using html rgb color codes
;
; Usage:
; - `rgb_color #FFFFFF`
;
; Outputs:
; - `DW $7FFF`
MACRO rgb_color
    ASSERT (STRIN("\1", "#") == 1 && (STRLEN("\1") == 4 || STRLEN("\1") == 7)), \
        "rgb_color requires codes formated as #xxx or #xxxxxx and instead parsed \1."
    
    DEF len  EQU STRLEN("\1")
    DEF code EQUS STRRPL("\1", "#", "$")
    DEF arg  EQU {code}

    IF len == 7
        DEF red EQU ((arg & $FF0000) >> 16) / 8
        DEF grn EQU ((arg & $00FF00) >>  8) / 8
        DEF blu EQU ((arg & $0000FF) >>  0) / 8
    ELSE
        DEF red EQU (((arg & $F00) >> 4) ^ ((arg & $F00) >> 8)) / 8
        DEF grn EQU (((arg & $0F0) >> 0) ^ ((arg & $0F0) >> 4)) / 8
        DEF blu EQU (((arg & $00F) << 4) ^ ((arg & $00F) >> 0)) / 8
    ENDC

    DW ((red) << 0) + ((grn) << 5) + ((blu) << 10)

    PURGE len, code, arg, red, grn, blu
ENDM
