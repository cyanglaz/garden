extends GutTest

const DATA := preload("res://tests/unit/save/datas/test_character_data.tres")
const ACTION_DATA := preload("res://tests/unit/save/datas/test_action_data.tres")

var obj:CharacterData

func before_each():
	obj = DATA.get_duplicate()
	obj.hp.spend(1)
	obj.tile_id = 505
	var pending_actions := [ACTION_DATA.get_duplicate(), ACTION_DATA.get_duplicate()]
	obj.pending_actions = pending_actions
	obj.face_direction = Vector2.LEFT
	obj.turn_state = CharacterData.TurnState.WALKED
	obj.deployed = true
	obj.ordered_moves = [1, 1]
	obj.order_index = 1
	obj.turn_started = true
# small size
func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj:CharacterData = Snapshot.load_save(dictionary)
	assert_true(loaded_obj is CharacterData)
	SaveTestHelper.recursive_compare(self, obj, loaded_obj)
	assert_eq_deep(obj.action_datas, loaded_obj.action_datas)
	assert_eq(obj.id, loaded_obj.id)
	assert_eq(obj.display_name, loaded_obj.display_name)
	assert_eq(obj.type, loaded_obj.type)
	assert_eq(obj.max_hp, loaded_obj.max_hp)
	assert_eq(obj.movement_speed, loaded_obj.movement_speed)
	assert_eq(obj.on_dead_action_data, loaded_obj.on_dead_action_data)
	assert_eq(obj.fixed_face_direction, loaded_obj.fixed_face_direction)

func _dictionary() -> Dictionary:
	return {
			"Scrypt": CharacterData,
			"ResourcePath": "res://tests/unit/save/datas/test_character_data.tres",
			"tile_id": 505,
			"hp": obj.hp._snapshot.save(),
			"pending_actions": [obj.pending_actions[0]._snapshot.save(), obj.pending_actions[1]._snapshot.save()],
			"ordered_moves": [1, 1],
			"face_direction": Vector2.LEFT,
			"turn_state": CharacterData.TurnState.WALKED,
			"deployed": true,
			"order_index": 1,
			"turn_started": true,
			"unit_id": -1,
			"obtained_upgrades": {},
			"action_datas": [],
			"start_turn_action_data": null,
			"end_turn_action_data": null,
			"on_dead_action_data": null,
			"on_hurt_action_data": null,
			"push_resistance": 0,
			"movement_speed": 2,
			}
	
