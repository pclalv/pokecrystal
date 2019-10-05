	object_const_def ; object_event constants
	const GOLDENRODFLOWERSHOP_TEACHER
	const GOLDENRODFLOWERSHOP_FLORIA

GoldenrodFlowerShop_MapScripts:
	db 0 ; scene scripts

	db 0 ; callbacks

FlowerShopTeacherScript:
.ckir_BEFORE_CHECKEVENT_EVENT_FOUGHT_SUDOWOODO:
	;; don't screw the player if they defeat sudowoodo before
	;; visiting the flower shop.
	checkevent EVENT_PLAYERS_HOUSE_MOM_2
.ckir_AFTER_CHECKEVENT_EVENT_FOUGHT_SUDOWOODO:
	iftrue .Lalala
	checkevent EVENT_GOT_SQUIRTBOTTLE
	iftrue .GotSquirtbottle
.ckir_BEFORE_checkevent_EVENT_MET_FLORIA::
        ;; don't force the player to talk to Floria at the Sudowood.
        ;; say the player gets the Squirtbottle, skips Azalea Town,
        ;; and goes directly from Violet to Goldenrod. the first time
	;; the player passes the Sudowoodo, Floria won't be there,
        ;; because arriving in Goldenrod is the trigger for Floria being
	;; there. effectively, the player has to waste time going BACK
        ;; to the tree just to talk to here.
	checkevent EVENT_MET_FLORIA
.ckir_AFTER_checkevent_EVENT_MET_FLORIA::
	iffalse .HaventMetFloria
.ckir_BEFORE_CHECKEVENT_EVENT_TALKED_TO_FLORIA_AT_FLOWER_SHOP:
	;; it shouldn't matter whether the player talks to Floria or not.
	checkevent EVENT_GOT_A_POKEMON_FROM_ELM
.ckir_AFTER_CHECKEVENT_EVENT_TALKED_TO_FLORIA_AT_FLOWER_SHOP:
	iffalse .Lalala
        ;; change this to check if the player defeated whitney, for
        ;; the sake of badge randomization. otherwise, plainbadge will
        ;; always have to appear early.
        ;; checkevent EVENT_BEAT_WHITNEY

        ;; on second thought, it's fine as is. the player already
        ;; starts out with way too many key items.
.ckir_BEFORE_checkflag_ENGINE_PLAINBADGE::
	checkflag ENGINE_PLAINBADGE
.ckir_AFTER_checkflag_ENGINE_PLAINBADGE::
	iffalse .NoPlainBadge
	faceplayer
	opentext
	writetext GoldenrodFlowerShopTeacherHeresTheSquirtbottleText
	promptbutton
.ckir_BEFORE_verbosegiveitem_SQUIRTBOTTLE:
	verbosegiveitem SQUIRTBOTTLE
.ckir_AFTER_verbosegiveitem_SQUIRTBOTTLE:
	setevent EVENT_GOT_SQUIRTBOTTLE
	closetext
	setevent EVENT_FLORIA_AT_SUDOWOODO
	clearevent EVENT_FLORIA_AT_FLOWER_SHOP
	end

.Lalala:
	turnobject GOLDENRODFLOWERSHOP_TEACHER, LEFT
	opentext
	writetext GoldenrodFlowerShopTeacherLalalaHavePlentyOfWaterText
	waitbutton
	closetext
	end

.GotSquirtbottle:
	jumptextfaceplayer GoldenrodFlowerShopTeacherDontDoAnythingDangerousText

.NoPlainBadge:
	jumptextfaceplayer GoldenrodFlowerShopTeacherAskWantToBorrowWaterBottleText

.HaventMetFloria:
	jumptextfaceplayer GoldenrodFlowerShopTeacherMySisterWentToSeeWigglyTreeRoute36Text

FlowerShopFloriaScript:
	faceplayer
	opentext
	checkevent EVENT_FOUGHT_SUDOWOODO
	iftrue .FoughtSudowoodo
	checkevent EVENT_GOT_SQUIRTBOTTLE
	iftrue .GotSquirtbottle
	writetext GoldenrodFlowerShopFloriaWonderIfSisWillLendWaterBottleText
	waitbutton
	closetext
	setevent EVENT_TALKED_TO_FLORIA_AT_FLOWER_SHOP
	setevent EVENT_FLORIA_AT_FLOWER_SHOP
	clearevent EVENT_FLORIA_AT_SUDOWOODO
	end

.GotSquirtbottle:
	writetext GoldenrodFlowerShopFloriaYouBeatWhitneyText
	waitbutton
	closetext
	end

.FoughtSudowoodo:
	writetext GoldenrodFlowerShopFloriaItReallyWasAMonText
	waitbutton
	closetext
	end

FlowerShopShelf1:
; unused
	jumpstd PictureBookshelfScript

FlowerShopShelf2:
; unused
	jumpstd MagazineBookshelfScript

FlowerShopRadio:
; unused
	jumpstd Radio2Script

GoldenrodFlowerShopTeacherMySisterWentToSeeWigglyTreeRoute36Text:
	text "Have you seen that"
	line "wiggly tree that's"

	para "growing on ROUTE"
	line "36?"

	para "My little sister"
	line "got all excited"

	para "and went to see"
	line "it…"

	para "I'm worried… Isn't"
	line "it dangerous?"
	done

GoldenrodFlowerShopTeacherAskWantToBorrowWaterBottleText:
	text "Do you want to"
	line "borrow the water"

	para "bottle too?"
	line "I don't want you"

	para "doing anything"
	line "dangerous with it."
	done

GoldenrodFlowerShopTeacherHeresTheSquirtbottleText:
	text "Oh, you're better"
	line "than WHITNEY…"

	para "You'll be OK,"
	line "then. Here's the"
	cont "SQUIRTBOTTLE!"
	done

GoldenrodFlowerShopTeacherDontDoAnythingDangerousText:
	text "Don't do anything"
	line "too dangerous!"
	done

GoldenrodFlowerShopTeacherLalalaHavePlentyOfWaterText:
	text "Lalala lalalala."
	line "Have plenty of"
	cont "water, my lovely!"
	done

GoldenrodFlowerShopFloriaWonderIfSisWillLendWaterBottleText:
	text "When I told my sis"
	line "about the jiggly"

	para "tree, she told me"
	line "it's dangerous."

	para "If I beat WHITNEY,"
	line "I wonder if she'll"

	para "lend me her water"
	line "bottle…"
	done

GoldenrodFlowerShopFloriaYouBeatWhitneyText:
	text "Wow, you beat"
	line "WHITNEY? Cool!"
	done

GoldenrodFlowerShopFloriaItReallyWasAMonText:
	text "So it really was a"
	line "#MON!"
	done

GoldenrodFlowerShop_MapEvents:
	db 0, 0 ; filler

	db 2 ; warp events
	warp_event  2,  7, GOLDENROD_CITY, 6
	warp_event  3,  7, GOLDENROD_CITY, 6

	db 0 ; coord events

	db 0 ; bg events

	db 2 ; object events
	object_event  2,  4, SPRITE_TEACHER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, FlowerShopTeacherScript, -1
	object_event  5,  6, SPRITE_LASS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, FlowerShopFloriaScript, EVENT_FLORIA_AT_FLOWER_SHOP
