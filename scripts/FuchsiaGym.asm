FuchsiaGym_Script:
	call EnableAutoTextBoxDrawing
	ld hl, FuchsiaGymTrainerHeaders
	ld de, FuchsiaGym_ScriptPointers
	ld a, [wFuchsiaGymCurScript]
	call ExecuteCurMapScriptInTable
	ld [wFuchsiaGymCurScript], a
	ret

FuchsiaGymResetScripts:
	xor a ; SCRIPT_FUCHSIAGYM_DEFAULT
	ld [wJoyIgnore], a
	ld [wFuchsiaGymCurScript], a
	ld [wCurMapScript], a
	ret

FuchsiaGym_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_FUCHSIAGYM_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_FUCHSIAGYM_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_FUCHSIAGYM_END_BATTLE
	dw_const FuchsiaGymKogaPostBattleScript,        SCRIPT_FUCHSIAGYM_KOGA_POST_BATTLE

FuchsiaGymKogaPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jp z, FuchsiaGymResetScripts
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, KogaRematchPostBattle
; fallthrough
FuchsiaGymReceiveTM06:
	ld a, TEXT_FUCHSIAGYM_KOGA_SOUL_BADGE_INFO
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	SetEvent EVENT_BEAT_KOGA
	lb bc, TM_TOXIC, 1
	call GiveItem
	jr nc, .BagFull
	ld a, TEXT_FUCHSIAGYM_KOGA_RECEIVED_TM06
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	SetEvent EVENT_GOT_TM06
	jr .gymVictory
.BagFull
	ld a, TEXT_FUCHSIAGYM_KOGA_TM06_NO_ROOM
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
.gymVictory
	ld hl, wObtainedBadges
	set BIT_SOULBADGE, [hl]
	ld hl, wBeatGymFlags
	set BIT_SOULBADGE, [hl]

	; deactivate gym trainers
	SetEventRange EVENT_BEAT_FUCHSIA_GYM_TRAINER_0, EVENT_BEAT_FUCHSIA_GYM_TRAINER_5

	jp FuchsiaGymResetScripts

KogaRematchPostBattle:
	ld a, TEXT_FUCHSIAGYM_REMATCH_POST_BATTLE
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	jp FuchsiaGymResetScripts

FuchsiaGym_TextPointers:
	def_text_pointers
	dw_const FuchsiaGymKogaText,              TEXT_FUCHSIAGYM_KOGA
	dw_const FuchsiaGymRocker1Text,           TEXT_FUCHSIAGYM_ROCKER1
	dw_const FuchsiaGymRocker2Text,           TEXT_FUCHSIAGYM_ROCKER2
	dw_const FuchsiaGymRocker3Text,           TEXT_FUCHSIAGYM_ROCKER3
	dw_const FuchsiaGymRocker4Text,           TEXT_FUCHSIAGYM_ROCKER4
	dw_const FuchsiaGymRocker5Text,           TEXT_FUCHSIAGYM_ROCKER5
	dw_const FuchsiaGymRocker6Text,           TEXT_FUCHSIAGYM_ROCKER6
	dw_const FuchsiaGymJanineText,            TEXT_FUCHSIAGYM_JANINE
	dw_const FuchsiaGymGymGuideText,          TEXT_FUCHSIAGYM_GYM_GUIDE
	dw_const FuchsiaGymKogaSoulBadgeInfoText, TEXT_FUCHSIAGYM_KOGA_SOUL_BADGE_INFO
	dw_const FuchsiaGymKogaReceivedTM06Text,  TEXT_FUCHSIAGYM_KOGA_RECEIVED_TM06
	dw_const FuchsiaGymKogaTM06NoRoomText,    TEXT_FUCHSIAGYM_KOGA_TM06_NO_ROOM
	dw_const FuchsiaGymRematchPostBattleText, TEXT_FUCHSIAGYM_REMATCH_POST_BATTLE

FuchsiaGymTrainerHeaders:
	def_trainers 2
FuchsiaGymTrainerHeader0:
	trainer EVENT_BEAT_FUCHSIA_GYM_TRAINER_0, 2, FuchsiaGymRocker1BattleText, FuchsiaGymRocker1EndBattleText, FuchsiaGymRocker1AfterBattleText
FuchsiaGymTrainerHeader1:
	trainer EVENT_BEAT_FUCHSIA_GYM_TRAINER_1, 2, FuchsiaGymRocker2BattleText, FuchsiaGymRocker2EndBattleText, FuchsiaGymRocker2AfterBattleText
FuchsiaGymTrainerHeader2:
	trainer EVENT_BEAT_FUCHSIA_GYM_TRAINER_2, 4, FuchsiaGymRocker3BattleText, FuchsiaGymRocker3EndBattleText, FuchsiaGymRocker3AfterBattleText
FuchsiaGymTrainerHeader3:
	trainer EVENT_BEAT_FUCHSIA_GYM_TRAINER_3, 2, FuchsiaGymRocker4BattleText, FuchsiaGymRocker4EndBattleText, FuchsiaGymRocker4AfterBattleText
FuchsiaGymTrainerHeader4:
	trainer EVENT_BEAT_FUCHSIA_GYM_TRAINER_4, 2, FuchsiaGymRocker5BattleText, FuchsiaGymRocker5EndBattleText, FuchsiaGymRocker5AfterBattleText
FuchsiaGymTrainerHeader5:
	trainer EVENT_BEAT_FUCHSIA_GYM_TRAINER_5, 2, FuchsiaGymRocker6BattleText, FuchsiaGymRocker6EndBattleText, FuchsiaGymRocker6AfterBattleText
FuchsiaGymTrainerHeader6:
	trainer EVENT_BEAT_FUCHSIA_GYM_TRAINER_6, 4, FuchsiaGymJanineBattleText, FuchsiaGymJanineEndBattleText, FuchsiaGymJanineAfterBattleText	
	db -1 ; end

FuchsiaGymKogaText:
	text_asm
	CheckEvent EVENT_BEAT_KOGA
	jr z, .beforeBeat
	CheckEventReuseA EVENT_GOT_TM06
	jr nz, .afterBeat
	call z, FuchsiaGymReceiveTM06
	call DisableWaitingAfterTextDisplay
	rst TextScriptEnd
.afterBeat
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, .KogaRematch
	ld hl, .PostBattleAdviceText
	rst _PrintText
	rst TextScriptEnd
.beforeBeat
	ld hl, .BeforeBattleText
	rst _PrintText
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	ld hl, .ReceivedSoulBadgeText
	ld de, .ReceivedSoulBadgeText
	call SaveEndBattleTextPointers
	farcall GetBadgesObtained
	ld a, [wNumSetBits]
	cp 5
	jr nc, .Koga6thGym
	jr .Koga5thGym
.KogaRematch
	ld hl, .PreBattleRematch1Text
	rst _PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .refused
	ld hl, .PreBattleRematch2Text
	rst _PrintText
	call Delay3
	ld a, OPP_KOGA
	ld [wCurOpponent], a
	ld a, 3
	ld [wTrainerNo], a
	ld a, $4 ; new script
	ld [wFuchsiaGymCurScript], a
	ld [wCurMapScript], a
	jr .endBattle
.refused
	ld hl, .PreBattleRematchRefusedText
	rst _PrintText
	rst TextScriptEnd
.Koga6thGym
	call Delay3
	ld a, OPP_KOGA
	ld [wCurOpponent], a
	ld a, 2
	ld [wTrainerNo], a
	ld a, $4 ; new script
	ld [wFuchsiaGymCurScript], a
	ld [wCurMapScript], a
	jr .afterBattle
.Koga5thGym
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
.afterBattle
	ld a, $5
	ld [wGymLeaderNo], a
	xor a
	ldh [hJoyHeld], a
.endBattle
	ld a, SCRIPT_FUCHSIAGYM_KOGA_POST_BATTLE
	ld [wFuchsiaGymCurScript], a
	rst TextScriptEnd

.BeforeBattleText:
	text_far _FuchsiaGymKogaBeforeBattleText
	text_end

.ReceivedSoulBadgeText:
	text_far _FuchsiaGymKogaReceivedSoulBadgeText
	text_end

.PostBattleAdviceText:
	text_far _FuchsiaGymKogaPostBattleAdviceText
	text_end

.PreBattleRematch1Text
	text_far _FuchsiaGymRematchPreBattle1Text
	text_end

.PreBattleRematchRefusedText
	text_far _GymRematchRefusedText
	text_end

.PreBattleRematch2Text
	text_far _FuchsiaGymPreRematchBattle2Text
	text_end

FuchsiaGymRematchPostBattleText:
	text_far _FuchsiaGymRematchPostBattleText
	text_end

FuchsiaGymKogaSoulBadgeInfoText:
	text_far _FuchsiaGymKogaSoulBadgeInfoText
	text_end

FuchsiaGymKogaReceivedTM06Text:
	text_far _FuchsiaGymKogaReceivedTM06Text
	sound_get_key_item
	text_far _FuchsiaGymKogaTM06ExplanationText
	text_end

FuchsiaGymKogaTM06NoRoomText:
	text_far _FuchsiaGymKogaTM06NoRoomText
	text_end

FuchsiaGymRocker1Text:
	text_asm
	ld hl, FuchsiaGymTrainerHeader0
	call TalkToTrainer
	rst TextScriptEnd

FuchsiaGymRocker1BattleText:
	text_far _FuchsiaGymRocker1BattleText
	text_end

FuchsiaGymRocker1EndBattleText:
	text_far _FuchsiaGymRocker1EndBattleText
	text_end

FuchsiaGymRocker1AfterBattleText:
	text_far _FuchsiaGymRocker1AfterBattleText
	text_end

FuchsiaGymRocker2Text:
	text_asm
	ld hl, FuchsiaGymTrainerHeader1
	call TalkToTrainer
	rst TextScriptEnd

FuchsiaGymRocker2BattleText:
	text_far _FuchsiaGymRocker2BattleText
	text_end

FuchsiaGymRocker2EndBattleText:
	text_far _FuchsiaGymRocker2EndBattleText
	text_end

FuchsiaGymRocker2AfterBattleText:
	text_far _FuchsiaGymRocker2AfterBattleText
	text_end

FuchsiaGymRocker3Text:
	text_asm
	ld hl, FuchsiaGymTrainerHeader2
	call TalkToTrainer
	rst TextScriptEnd

FuchsiaGymRocker3BattleText:
	text_far _FuchsiaGymRocker3BattleText
	text_end

FuchsiaGymRocker3EndBattleText:
	text_far _FuchsiaGymRocker3EndBattleText
	text_end

FuchsiaGymRocker3AfterBattleText:
	text_far _FuchsiaGymRocker3AfterBattleText
	text_end

FuchsiaGymRocker4Text:
	text_asm
	ld hl, FuchsiaGymTrainerHeader3
	call TalkToTrainer
	rst TextScriptEnd

FuchsiaGymRocker4BattleText:
	text_far _FuchsiaGymRocker4BattleText
	text_end

FuchsiaGymRocker4EndBattleText:
	text_far _FuchsiaGymRocker4EndBattleText
	text_end

FuchsiaGymRocker4AfterBattleText:
	text_far _FuchsiaGymRocker4AfterBattleText
	text_end

FuchsiaGymRocker5Text:
	text_asm
	ld hl, FuchsiaGymTrainerHeader4
	call TalkToTrainer
	rst TextScriptEnd

FuchsiaGymRocker5BattleText:
	text_far _FuchsiaGymRocker5BattleText
	text_end

FuchsiaGymRocker5EndBattleText:
	text_far _FuchsiaGymRocker5EndBattleText
	text_end

FuchsiaGymRocker5AfterBattleText:
	text_far _FuchsiaGymRocker5AfterBattleText
	text_end

FuchsiaGymRocker6Text:
	text_asm
	ld hl, FuchsiaGymTrainerHeader5
	call TalkToTrainer
	rst TextScriptEnd

FuchsiaGymRocker6BattleText:
	text_far _FuchsiaGymRocker6BattleText
	text_end

FuchsiaGymRocker6EndBattleText:
	text_far _FuchsiaGymRocker6EndBattleText
	text_end

FuchsiaGymRocker6AfterBattleText:
	text_far _FuchsiaGymRocker6AfterBattleText
	text_end

FuchsiaGymJanineText:
	text_asm
	ld hl, FuchsiaGymTrainerHeader6
	call TalkToTrainer
	rst TextScriptEnd

FuchsiaGymJanineBattleText:
	text_far _FuchsiaGymJanineBattleText
	text_end

FuchsiaGymJanineEndBattleText:
	text_far _FuchsiaGymJanineEndBattleText
	text_end

FuchsiaGymJanineAfterBattleText:
	text_far _FuchsiaGymJanineAfterBattleText
	text_end

FuchsiaGymGymGuideText:
	text_asm
	CheckEvent EVENT_BEAT_KOGA
	ld hl, .BeatKogaText
	jr nz, .afterBeat
	ld hl, .ChampInMakingText
.afterBeat
	rst _PrintText
	rst TextScriptEnd

.ChampInMakingText:
	text_far _FuchsiaGymGymGuideChampInMakingText
	text_end

.BeatKogaText:
	text_far _FuchsiaGymGymGuideBeatKogaText
	text_end
