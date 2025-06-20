extends GutTest

const DATA := preload("res://tests/unit/save/datas/test_tile_meta_data.tres")
const ACTION_DATA := preload("res://tests/unit/save/datas/test_action_data.tres")

var obj:TileMetaData

func before_each():
	obj = DATA.get_duplicate()
	obj.tile_id = 505
	var action_strategy = ActionStrategy.new()
	action_strategy.action_data = ACTION_DATA
	action_strategy.moves = [1]
	action_strategy.main_target_relative_tile_id = 0
	obj.action_strategy = action_strategy
	var pending_actions := [ACTION_DATA.get_duplicate(), ACTION_DATA.get_duplicate()]
	obj.pending_actions = pending_actions

# small size
func test_save():
	var dictionary := obj.get_duplicate()._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj:TileMetaData = Snapshot.load_save(dictionary)
	assert_true(loaded_obj is TileMetaData)
	SaveTestHelper.recursive_compare(self, obj, loaded_obj)
	assert_eq(obj.type, loaded_obj.type)
	assert_eq(obj.action_data, loaded_obj.action_data)
	assert_eq(obj.display_name, loaded_obj.display_name)
	assert_eq(obj.description, loaded_obj.description)
	assert_eq(obj.source_coord, loaded_obj.source_coord)

func _dictionary() -> Dictionary:
	return {
			"Scrypt": TileMetaData,
			"ResourcePath": "res://tests/unit/save/datas/test_tile_meta_data.tres",
			"tile_id": 505,
			"action_strategy": obj.action_strategy._snapshot.save(),
			"pending_actions": [obj.pending_actions[0]._snapshot.save(), obj.pending_actions[1]._snapshot.save()],
			"discovered": true,
			}
	
