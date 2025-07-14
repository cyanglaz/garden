class_name NewCardController
extends RefCounted

const PLUS_PERCENTAGE_SCALE := 0.05

const NEW_CARD_COUNT := 3

var _game_main:GameMain: get = _get_game_main
var _weak_game_main:WeakRef

func _init(game_main:GameMain) -> void:
	_weak_game_main = weakref(game_main)

func show_new_cards(_level:int) -> void:
	pass
	#var new_cards := MainDatabase.player_ball_database.roll_balls(NEW_CARD_COUNT, level)
	#var final_new_cards:Array[BingoBallData] = []
	#for card in new_cards:
		#if card.rarity == BingoBallData.Rarity.RARE:
			## Does not provide plus rare card
			#continue
		#var roll := randf_range(0.0, 1.0)
		#if roll < PLUS_PERCENTAGE_SCALE * level:
			#card = MainDatabase.ball_database.get_data_by_id(card.upgrade_to_id)
		#final_new_cards.append(card)
#
	#_game_main.animate_show_upgrade_main(new_cards)

func _insert_ball(ball_data:BingoBallData) -> void:
	_game_main._player.insert_ball(ball_data)

func handle_new_card_selected(bingo_ball_data:BingoBallData) -> void:
	assert(bingo_ball_data)
	_insert_ball(bingo_ball_data)

func _get_game_main() -> GameMain:
	return _weak_game_main.get_ref()
