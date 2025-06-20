extends GutTest

var obj:HP

func before_each():
	obj = HP.new()
	obj.setup(2, 3)
	obj.show_damage_label = false
	obj.shield = 2

# small size
func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj := Snapshot.load_save(dictionary)
	assert_true(loaded_obj is HP)
	SaveTestHelper.recursive_compare(self, obj, loaded_obj)

func _dictionary() -> Dictionary:
	return {
			"Scrypt": HP,
			"value": 2,
			"max_value": 3,
			"estimate_value": 2,
			"show_damage_label": false,
			"shield": 2,
			}
