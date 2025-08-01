; PureRGBnote: ADDED: subroutines for choosing which color palette the type icons in the movedex should use, and which icon images to use for which type.

; input d = type ID
; output d = palette ID
GetTypePalette:
	ld hl, TypePaletteMapping
	ld a, d ; d = type ID
	ld b, 0
	ld c, a
	add hl, bc ; which palette to use for this type
	ld a, [hl]
	ld d, a
	ret

TypePaletteMapping:
	db PAL_WHITEMON;normal
	db PAL_BROWNMON;fighting
	db PAL_MEWMON2;flying
	db PAL_PURPLEMON;poison
	db PAL_REDMON;ground
	db PAL_GREYMON;rock
	db PAL_WHITEMON;typeless/bird
	db PAL_GREENMON;bug
	db PAL_BLACKMON;ghost
	db PAL_BLACK2; crystal (no moves use this type)
	db PAL_REDMON ; bonemerang (same as ground)
	db PAL_BLACK2;unused
	db PAL_BLACK2;unused
	db PAL_BLACK2;unused
	db PAL_BLACK2;unused
	db PAL_BLACK2;unused
	db PAL_BLACK2;unused
	db PAL_WHITEMON;tri
	db PAL_BLACK2;unused
	db PAL_BLACK2;unused
	db PAL_REDMON;fire
	db PAL_BLUEMON;water
	db PAL_GREENMON;grass
	db PAL_YELLOWMON;electric
	db PAL_PINKMON;psychic
	db PAL_CYANMON;ice
	db PAL_MEWMON3;dragon

; input d = type ID
LoadTypeIcon:
	ld hl, TypeGraphicMapping
	ld a, d ; d = type ID
	ld b, 0
	ld c, a
	add hl, bc 
	add hl, bc ; pointer to which function to use for this type
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	lb bc, BANK(NormalTypeIcon), 4
	ld hl, vChars1 + $400
	jp CopyVideoData

TypeGraphicMapping:
	dw NormalTypeIcon
	dw FightingTypeIcon;fighting
	dw FlyingTypeIcon;flying
	dw PoisonTypeIcon;poison
	dw GroundTypeIcon;ground
	dw RockTypeIcon;rock
	dw NormalTypeIcon ;typeless/bird
	dw BugTypeIcon;bug
	dw GhostTypeIcon;ghost
	dw 0 ; crystal (no moves use this type)
	dw GroundTypeIcon ; bonemerang
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw TriTypeIcon ;tri
	dw 0 ;unused (floating - no moves use this type)
	dw 0 ;unused (magma - no moves use this type)
	dw FireTypeIcon;fire
	dw WaterTypeIcon;water
	dw GrassTypeIcon;grass
	dw ElectricTypeIcon;electric
	dw PsychicTypeIcon;psychic
	dw IceTypeIcon;ice
	dw DragonTypeIcon;dragon