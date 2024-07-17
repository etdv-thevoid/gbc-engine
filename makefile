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
ASFLAGS  = -p ${PADVALUE} $(addprefix -I ,${INCDIRS}) $(addprefix -W ,${WARNINGS}) -h
LDFLAGS  = -p ${PADVALUE}
FIXFLAGS = -p ${PADVALUE} -t "${TITLE}" -i "${GAMEID}" -k "${LICENSEE}" -l ${OLDLIC} -m ${MBC} -n ${VERSION} -r ${SRAMSIZE}

# The list of ASM files that RGBASM will be invoked on.
SRCS = $(call rwildcard,source,*.asm)

## Project-specific configuration
# Use this to override the above
include project.mk

# `all` (Default target): build the ROM
all: ${ROM}
.PHONY: all

# `clean`: Remove build directories (assets, bin, and dist folders)
clean:
	rm -rf assets/ bin/ dist/
.PHONY: clean

# `rebuild`: Build everything from scratch
# It's important to do these two in order if we're using more than one job
rebuild:
	${MAKE} clean
	${MAKE} all
.PHONY: rebuild


assets/%.2bpp: images/%.png
	@mkdir -p "${@D}"
	${RGBGFX} -o $@ $<

assets/%.1bpp: images/%.png
	@mkdir -p "${@D}"
	${RGBGFX} -d 1 -o $@ $<

# Define how to compress files using the PackBits16 codec
# Compressor script requires Python 3
assets/%.pb16: assets/% source/tools/pb16.py
	@mkdir -p "${@D}"
	source/tools/pb16.py $< assets/$*.pb16

assets/%.pb16.size: assets/%
	@mkdir -p "${@D}"
	printf 'def NB_PB16_BLOCKS equ ((%u) + 15) / 16\n' "$$(wc -c <$<)" > assets/$*.pb16.size

# Define how to compress files using the PackBits8 codec
# Compressor script requires Python 3
assets/%.pb8: assets/% source/tools/pb8.py
	@mkdir -p "${@D}"
	source/tools/pb8.py $< assets/$*.pb8

assets/%.pb8.size: assets/%
	@mkdir -p "${@D}"
	printf 'def NB_PB8_BLOCKS equ ((%u) + 7) / 8\n' "$$(wc -c <$<)" > assets/$*.pb8.size


# How to build a ROM.
# Notice that the build date is always refreshed.
dist/%.${ROMEXT}: $(patsubst source/%.asm,bin/%.obj,${SRCS})
	@mkdir -p "${@D}"
#	${RGBASM} ${ASFLAGS} -o bin/build_date.obj source/assets/build_date.asm
	${RGBLINK} ${LDFLAGS} -m dist/$*.map -n dist/$*.sym -o $@ $^ \
	&& ${RGBFIX} -v ${FIXFLAGS} $@

# `.mk` files are auto-generated dependency lists of the source ASM files, to save a lot of hassle.
# Also add all obj dependencies to the dep file too, so Make knows to remake it.
# Caution: some of these flags were added in RGBDS 0.4.0, using an earlier version WILL NOT WORK
# (and produce weird errors).
bin/%.mk: source/%.asm
	@mkdir -p "${@D}"
	${RGBASM} ${ASFLAGS} -M $@ -MG -MP -MQ ${@:.mk=.obj} -MQ $@ -o ${@:.mk=.obj} $<
# DO NOT merge this with the rule above, otherwise Make will assume that the `.obj` file is generated,
# even when it isn't!
# This causes weird issues that depend, among other things, on the version of Make.
bin/%.obj: bin/%.mk
	@touch $@

ifeq ($(filter clean,${MAKECMDGOALS}),)
include $(patsubst source/%.asm,bin/%.mk,${SRCS})
endif

