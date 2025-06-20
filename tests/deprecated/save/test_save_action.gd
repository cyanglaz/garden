extends GutTest

const ACTION_DATA := preload("res://tests/unit/save/datas/test_action_data.tres")

var obj:Action

func before_each():
	obj = Action.new()
	obj.id = 1
	obj.data = ACTION_DATA.get_duplicate()
	obj.emitting_from_position_id = 202
	obj.target_relative_position = [1, 5]
	obj.main_target_relative_position = 101
	obj.main_action = true
	obj.persistent_meta_tile_flag = false
	obj._action_received = false
	obj._evaluated_tile_id = 101

# small size
func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj:Action = Snapshot.load_save(dictionary)
	assert_true(loaded_obj is Action)
	SaveTestHelper.recursive_compare(self, obj, loaded_obj)

func _dictionary() -> Dictionary:
	return {
			"Scrypt": Action,
			"id": 1,
			"data": obj.data._snapshot.save(),
			"emitting_from_position_id": 202,
			"target_relative_position": [1, 5],
			"main_target_relative_position": 101,
			"main_action": true,
			"persistent_meta_tile_flag": false,
			"_action_received": false,
			"_evaluated_tile_id": 101,
			}
