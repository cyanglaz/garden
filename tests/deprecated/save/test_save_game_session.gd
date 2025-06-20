extends GutTest

const DATA := preload("res://tests/unit/save/datas/test_player_data.tres")
const GAME_SESSION_SCENE := preload("res://scenes/game_session/game_session.tscn")
const ARSENAL_DATA := preload("res://tests/unit/save/datas/test_action_data.tres")

var obj:GameSession

func before_each():
	obj = autofree(GAME_SESSION_SCENE.instantiate())
	add_child(obj)
	obj.gold_deposit._count = 5
	obj.level_info.go_to_next_level()

#func after_each() -> void:
	#await wait_frames(1)

func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var saved_data := obj._snapshot.save()
	obj.gold_deposit.gain(6)
	obj.level_info.start_combat()
	await wait_frames(1)
	obj._snapshot.load_self_save(saved_data)
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
	 			 _dictionary())

func _dictionary() -> Dictionary:
	return {
			"Scrypt": GameSession,
			"gold_deposit": obj.gold_deposit._snapshot.save(),
			"level_info": obj.level_info._snapshot.save(),
			"learned_skills": {},
			"item_inventory": obj.item_inventory._snapshot.save(),
			"card_inventory": obj.card_inventory._snapshot.save(),
			}
