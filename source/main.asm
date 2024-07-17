INCLUDE "includes/constants.inc"
INCLUDE "includes/macros.inc"
;INCLUDE "includes/charmap.inc"

INCLUDE "libraries/gbc-engine-core/gbc-engine-core.inc"
    gbc_engine_core_version 0.2.0


SECTION "Program Main", ROM0

_Main::
    ; You code goes here!
    ld a, BANK(xExample)
    ld hl, xExample
    call _FarCall
    ret

ENDSECTION


SECTION "Program Crash", ROM0

_CrashHandler::
    ; You code goes here!
.loop
    halt
    nop
    jr .loop
    ret

ENDSECTION