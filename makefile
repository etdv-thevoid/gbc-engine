.SUFFIXES:

# Recursive `wildcard` function.
rwildcard = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

RGBDS   ?= # Shortcut if you want to use a local copy of RGBDS.
RGBASM  := ${RGBDS}rgbasm
RGBLINK := ${RGBDS}rgblink
RGBFIX  := ${RGBDS}rgbfix
RGBGFX  := ${RGBDS}rgbgfx

ROM = dist/${ROMNAME}.${ROMEXT}

# Argument constants
INCDIRS  = source/ includes/
WARNINGS = all extra
ASMFLAGS = -p ${PADVALUE} $(addprefix -I ,${INCDIRS}) $(addprefix -W ,${WARNINGS})
LNKFLAGS = -p ${PADVALUE}
FIXFLAGS = -p ${PADVALUE} -t "${TITLE}" -i "${GAMEID}" -k "${LICENSEE}" -l ${OLDLIC} -m ${MBC} -n ${VERSION} -r ${SRAMSIZE}
GFXFLAGS = 

# The list of ASM files that RGBASM will be invoked on.
SRCS = $(call rwildcard,source,*.asm)

# Lists of intermediate asset files that 'clean' will remove.
2BPP = $(call rwildcard,assets,*.2bpp)
1BPP = $(call rwildcard,assets,*.1bpp)

## Project-specific configuration
# Use this to override the above
include project.mk

# `rom` (Default target): build the ROM
rom: ${ROM}
.PHONY: rom

# `clean`: Remove build directories (temp/ and dist/) and intermediate asset files
clean:
	@rm -rf temp/ dist/ ${2BPP} ${1BPP}
.PHONY: clean

# `rebuild`: Build everything from scratch
rebuild:
	${MAKE} clean
	${MAKE} rom
.PHONY: rebuild


# How to convert graphics
assets/%.2bpp: assets/%.png
	${RGBGFX} ${GFXFLAGS} -o $@ $<

assets/%.1bpp: assets/%.png
	${RGBGFX} ${GFXFLAGS} -d 1 -o $@ $<


# How to build `.mk` file dependency lists
temp/%.mk: source/%.asm
	@mkdir -p "${@D}"
	${RGBASM} ${ASMFLAGS} -M $@ -MG -MP -MQ ${@:.mk=.obj} -MQ $@ -o ${@:.mk=.obj} $<

# How to compile object files using the `.mk` files
temp/%.obj: temp/%.mk
	@touch $@

# Include `.mk` file dependency lists
ifeq ($(filter clean,${MAKECMDGOALS}),)
include $(patsubst source/%.asm,temp/%.mk,${SRCS})
endif

# How to build a ROM
# Note how libraries.inc is rebuilt and linked every time
dist/%.${ROMEXT}: $(patsubst source/%.asm,temp/%.obj,${SRCS})
	@mkdir -p "${@D}"
	${RGBASM} -p ${PADVALUE} -o temp/libraries.obj libraries/libraries.inc \
	&& ${RGBLINK} ${LNKFLAGS} -m dist/$*.map -n dist/$*.sym -o $@ temp/libraries.obj $^ \
	&& ${RGBFIX} -v ${FIXFLAGS} $@
