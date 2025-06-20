extends GutTest

var obj:=ResourcePoint.new()

func before_each():
	obj = ResourcePoint.new()
	obj.setup(2, 3)

# small size
func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj := Snapshot.load_save(dictionary)
	assert_true(loaded_obj is ResourcePoint)
	for key in obj._snapshot._properties_to_save:
		assert_eq(obj.get(key), loaded_obj.get(key))
	
func _dictionary() -> Dictionary:
	return {
			"Scrypt": ResourcePoint,
			"value": 2,
			"max_value": 3,
			"estimate_value": 2,
			}
