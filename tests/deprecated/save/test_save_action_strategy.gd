extends GutTest

var obj:ActionStrategy

func before_each():
	obj = ActionStrategy.new()
	obj.action_data = load("res://tests/unit/save/datas/test_action_data.tres")
	obj.main_target_relative_tile_id = 1
	obj.starting_position_id = 2
	obj.moves = [0]
	obj.persistent_meta_tile_flag = true

# small size
func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj := Snapshot.load_save(dictionary)
	assert_true(loaded_obj is ActionStrategy)
	SaveTestHelper.recursive_compare(self, obj, loaded_obj)

func _dictionary() -> Dictionary:
	return {
			"Scrypt": ActionStrategy,
			"action_data": load("res://tests/unit/save/datas/test_action_data.tres")._snapshot.save(),
			"main_target_relative_tile_id": 1,
			"starting_position_id": 2,
			"moves": [0],
			"persistent_meta_tile_flag": true,
			}