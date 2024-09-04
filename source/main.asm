INCLUDE "includes/includes.inc"

SECTION "Program Main Example", ROM0

/*
The main program loop.

`gbc-engine-core.inc` hands off code execution to a function labeled `_Main` when done with initial setup.

The function can assume the following:
- All ram areas are cleared
- LCD is off
- Interrupts are disabled
*/
_Main::
    ; Your code goes here!

    call _HelloWorld

    ; returning out of _Main will cause a crash!
    ret

ENDSECTION
