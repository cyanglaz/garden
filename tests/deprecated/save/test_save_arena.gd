extends GutTest

var obj:Arena
var params := RoomParams.new()

func before_each():
	obj = Arena.new()
	obj.generate_map(params)

# small size
func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj := Snapshot.load_save(dictionary)
	assert_true(loaded_obj is Arena)
	SaveTestHelper.recursive_compare(self, obj, loaded_obj)

func _dictionary() -> Dictionary:
	return {
			"Scrypt": Arena,
			"map": _get_map(),
			"width": params.map_width,
			"height": params.map_height,
			"half_width": obj.half_width,
			"half_height": obj.half_height,
			"entrance": obj.entrance,
			"exit": obj.exit,
			"_center": obj._center,
			}

func _get_map() -> Dictionary:
	var result:Dictionary
	for key in obj.map:
		result[key] = (obj.map[key] as TileMetaData)._snapshot.save()
	return result
