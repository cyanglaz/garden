extends GutTest

const ACTION_DATA := preload("res://tests/unit/save/datas/test_action_data.tres")
const PLAYER_DATA := preload("res://tests/unit/save/datas/test_player_data.tres")
const RESIDENCE_DATA := preload("res://data/characters/players/buildings/village.tres")
const PROP_DATA := preload("res://tests/unit/save/datas/test_prop_data.tres")
var obj:RoomData
var params := RoomParams.new()

func before_each():
	obj = RoomData.new()
	# Skip the initial castle discovery phase for this test
	obj.setup(params)
	obj.populate_for_next_wave(0, 1)
	obj.player_data = PLAYER_DATA.get_duplicate()
	obj.prop_datas = [PROP_DATA.get_duplicate(), PROP_DATA.get_duplicate()]
	obj.last_turn_to_summon_mob = 1
	obj.base_mobs_per_turn = 3

# small size
func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj := Snapshot.load_save(dictionary)
	assert_true(loaded_obj is RoomData)
	SaveTestHelper.recursive_compare(self, obj, loaded_obj)

func _dictionary() -> Dictionary:
	return {
			"Scrypt": RoomData,
			"room_id": obj.room_id,
			"arena": obj.arena._snapshot.save(),
			"mob_datas": _get_mob_datas(),
			"pending_mob_datas": _get_pending_mob_datas(),
			"player_data": obj.player_data._snapshot.save(),
			"state": obj.state,
			"difficulty": obj.difficulty,
			"mob_count":obj.mob_count._snapshot.save(),
			"last_turn_to_summon_mob": 1,
			"base_mobs_per_turn": 3,
			"prop_datas": _get_prop_datas_save(),
	}

func _get_mob_datas() -> Array:
	var result:Array
	for data:MobData in obj.mob_datas:
		result.append(data._snapshot.save())
	return result

func _get_pending_mob_datas() -> Array:
	var result:Array
	for data:MobData in obj.pending_mob_datas:
		result.append(data._snapshot.save())
	return result

func _get_player_datas_save() -> Array:
	var result:Array
	for data:PlayerData in obj.player_datas:
		result.append(data._snapshot.save())
	return result

func _get_prop_datas_save() -> Array:
	var result:Array
	for data:PropData in obj.prop_datas:
		result.append(data._snapshot.save())
	return result
