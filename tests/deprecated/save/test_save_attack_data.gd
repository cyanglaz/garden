extends GutTest

const DATA := preload("res://tests/unit/save/datas/test_attack_data.tres")

var obj:AttackData

func before_each():
	obj = DATA.get_duplicate()

# small size
func test_save():
	var dictionary := obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _dictionary())

func test_load():
	var dictionary := obj._snapshot.save()
	var loaded_obj:AttackData = Snapshot.load_save(dictionary)
	assert_true(loaded_obj is AttackData)
	SaveTestHelper.recursive_compare(self, obj, loaded_obj)
	assert_eq(obj.deploy_type, loaded_obj.deploy_type)
	assert_eq_deep(obj.tile_types, loaded_obj.tile_types)
	assert_eq_deep(obj.deploy_counts, loaded_obj.deploy_counts)
	assert_eq_deep(obj.deploy_area, loaded_obj.deploy_area)
	assert_eq(obj.deploy_range, loaded_obj.deploy_range)
	assert_eq(obj.delayed, loaded_obj.delayed)
	assert_eq(obj.sprite_indicator_name, loaded_obj.sprite_indicator_name)
	assert_eq(obj.display_name, loaded_obj.display_name)
	assert_eq(obj.description, loaded_obj.description)
	assert_eq_deep(obj.damage, loaded_obj.damage)

func _dictionary() -> Dictionary:
	return {
			"Scrypt": AttackData,
			"ResourcePath": "res://tests/unit/save/datas/test_attack_data.tres",
			"damage":obj.damage.duplicate(),
			"deploy_range": Vector2i(1, 1),
			}
	
