extends GutTest

const DATA := preload("res://tests/unit/save/datas/test_player_data.tres")

var obj:PlayerData

func before_each():
	obj = DATA.get_duplicate()

# small size
func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj:PlayerData = Snapshot.load_save(dictionary)
	assert_true(loaded_obj is PlayerData)
	SaveTestHelper.recursive_compare(self, obj, loaded_obj)

func _dictionary() -> Dictionary:
	return {
			"Scrypt": PlayerData,
			"ResourcePath": "res://tests/unit/save/datas/test_player_data.tres",
			"tile_id": -1,
			"hp": obj.hp._snapshot.save(),
			"pending_actions": [],
			"face_direction": Vector2.RIGHT,
			"turn_state": CharacterData.TurnState.NONE,
			"deployed": false,
			"ordered_moves": [],
			"order_index": -99,
			"turn_started": false,
			"unit_id": -1,
			"obtained_upgrades": {},
			"action_datas": [],
			"start_turn_action_data": null,
			"end_turn_action_data": null,
			"on_dead_action_data": null,
			"on_hurt_action_data": null,
			"push_resistance": 0,
			"movement_speed": 1,
			}
