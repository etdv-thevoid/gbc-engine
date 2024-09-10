INCLUDE "includes/includes.inc"


SECTION "Main State Loop Functions", ROM0

/*
`gbc-engine-core.inc` hands off code execution to
a function labeled `_Main` when done with initial setup.

The function can assume the following:
- All ram areas are cleared
- LCD is off
- Interrupts are disabled

As an example, the following function implements a simple
finite state machine loop. 
*/
_Main::
    ; Load font tiles
    call _LoadFontTilesBLK2

    ; Load palette colors
    call _LoadPalette

    ; Load sound effects and initialize `gbc-engine-core`'s sound driver
    call _LoadSoundEffects

    ; Enable VBlank Interrupt
    ; (enabling the Timer Interrupt is handled by the sound driver)
    ld a, IEF_VBLANK
    ldh [rIE], a

    ; fallthrough

_MainStateLoop:
    ; Anything below will be executed each time the main state changes!

    ; Turn off the screen
    call _ScreenOff

    ; Disable Interrupts
    di

    ; Reset VBlank Interrupt Handler function to default
    ld bc, _MainStateVBlankHandler
    rst _SetVBLHandler

    ; Enable Interrupts
    ei

    ; Jump to current main state's function
    ld a, [wMainStateCurrent]
    ld c, NUMBER_OF_MAIN_STATES
    ld hl, _MainStateJumpTable
    call _JumpTableBank

    ; Loop for as long as the current main state is valid
    ld a, [wMainStateCurrent]
    cp a, NUMBER_OF_MAIN_STATES
    jr c, _MainStateLoop

    ; Returning out of _Main will cause a crash!
    ret


/*
Banked Jump Table for each main state
*/
_MainStateJumpTable:
    DB BANK(xHelloWorld)
    DW xHelloWorld
    ASSERT (@ - _MainStateJumpTable == NUMBER_OF_MAIN_STATES * SIZE_OF_ADDRESS_TABLE_BANKED)


/*
Returns to the previous main state.
*/
_MainStatePrevious::
    ld a, [wMainStatePrevious]
    jr _MainStateNew


/*
Increments the current main state.
*/
_MainStateIncrement::
    ld a, [wMainStateCurrent]
    inc a
    ; fallthrough


/*
Sets the current main state.

Input:
- `a` = `MAIN_STATE_*` value
*/
_MainStateNew::
    push af

    ld a, [wMainStateCurrent]
    ld [wMainStatePrevious], a

    pop af
    ld [wMainStateCurrent], a
    ret


/*
Default VBlank Interrupt Handler

- Refreshes OAM
- Scans Key Input
*/
_MainStateVBlankHandler:
    call _RefreshOAM
    jp _ScanKeys


ENDSECTION


SECTION "Main State Loop Variables", WRAM0

wMainStateCurrent:
    DB

wMainStatePrevious:
    DB

ENDSECTION
