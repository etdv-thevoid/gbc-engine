INCLUDE "includes/includes.inc"


SECTION "Sound Effect Functions", ROM0

/*
- Set Timer Interrrupt Handler to `_UpdateSound`
- Initialize `gbc-engine-core`'s sound driver with sound data
*/
_LoadSoundEffects::
    ld bc, _UpdateSound
    rst _SetTIMHandler

    ld a, NUMBER_OF_SOUND_EFFECTS
    ld bc, _SoundEffectsPointerTable
    jp _InitSound

/*
Pointer Table for each sound effect
*/
_SoundEffectsPointerTable:
    DW _SfxCoin
    DW _SfxGameOver
    DW _SfxJump
    DW _SfxPercussion
    DW _NULL

/*
Simple coin collect jingle
*/
_SfxCoin:
    INCLUDE "assets/sound_effects/coin.sfx"

/*
Simple game over sting
*/
_SfxGameOver:
    INCLUDE "assets/sound_effects/game_over.sfx"

/*
Simple jump sound
*/
_SfxJump:
    INCLUDE "assets/sound_effects/jump.sfx"

/*
Simple percussion crash
*/
_SfxPercussion:
    INCLUDE "assets/sound_effects/percussion.sfx"

ENDSECTION
