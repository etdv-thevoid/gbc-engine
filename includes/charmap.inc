; Create new character map based on the default ASCII charmap but offset by 128.
; Useful for putting font tile into tile block 1
NEWCHARMAP offset_charmap

DEF SPACE_ASCII EQU 32  ; ASCII code for (space)
DEF TILE_START 	EQU 128

DEF CHARMAP_OFFSET EQU TILE_START + SPACE_ASCII

DEF CHAR_LIST EQUS STRCAT(#""" !"#$%&'()*+,-./""", \
						  #"""0123456789:;<=>?""", \
						  #"""@ABCDEFGHIJKLMNO""", \
						  #"""PQRSTUVWXYZ[\]^_""", \
						  #"""`abcdefghijklmno""", \
						  #"""pqrstuvwxyz{|}~©""")

FOR CHAR, STRLEN("{CHAR_LIST}")
	CHARMAP STRSUB("{CHAR_LIST}", CHAR + 1, 1), CHAR + CHARMAP_OFFSET
ENDR

PURGE SPACE_ASCII
PURGE TILE_START
PURGE CHARMAP_OFFSET
PURGE CHAR_LIST
