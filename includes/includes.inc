/*******************************************************************************
**
**  LIBRARIES
**
*******************************************************************************/

INCLUDE "libraries/hardware.inc/hardware.inc"
    rev_Check_hardware_inc 4.9.1

INCLUDE "libraries/gbc-engine-core/gbc-engine-core-macros.inc"
    gbc_engine_core_version 1.4.4

/*******************************************************************************
**
**  CONSTANTS
**
*******************************************************************************/

DEF TRUE    EQU 1
DEF FALSE   EQU 0


DEF SIZE_OF_ADDRESS_TABLE           EQU 2
DEF SIZE_OF_ADDRESS_TABLE_BANKED    EQU 3


RSRESET

DEF MAIN_STATE_HELLO_WORLD      RB

DEF NUMBER_OF_MAIN_STATES       RB 0


INCLUDE "includes/engine/palette.inc"
INCLUDE "includes/engine/sound.inc"
; Add your constants here!
