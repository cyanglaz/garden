extends GutTest

const DATA := preload("res://tests/unit/save/datas/test_player_data.tres")

var obj:PlayerSquad

func before_each():
	obj = PlayerSquad.new()

# small size
func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj:PlayerSquad = Snapshot.load_save(dictionary)
	assert_true(loaded_obj is PlayerSquad)
	SaveTestHelper.recursive_compare(self, obj, loaded_obj)

func _dictionary() -> Dictionary:
	return {
			"Scrypt": PlayerSquad,
			"_ending_turn": false,
			"_turn_id": 0,
			"_turn_started": false,
			}
