extends GutTest

# small size
func test_save_simple():
	var test_obj := SimpleObject.new()
	var dictionary := test_obj._snapshot.save()
	assert_eq_deep(dictionary, \
				 _simple_object_dictionary())

func test_load_simple():
	var test_obj := SimpleObject.new()
	var dictionary := test_obj._snapshot.save()
	var obj := Snapshot.load_save(dictionary)
	assert_true(obj is SimpleObject)
	_compare_simple_obj(obj, dictionary)
	

func test_save_complex():
	var test_obj := ComplexObject.new()
	var dictionary := test_obj._snapshot.save()
	assert_eq_deep(dictionary, \
			 {
				"Scrypt": ComplexObject,
				"var1": _simple_object_dictionary(),
			  	"var2": [_simple_object_dictionary(), _simple_object_dictionary()],
				"var3": {"key": _simple_object_dictionary()}	
				})

func test_load_complex():
	var test_obj := ComplexObject.new()
	var dictionary := test_obj._snapshot.save()
	var obj:ComplexObject = Snapshot.load_save(dictionary)
	assert_true(obj is ComplexObject)
	_compare_simple_obj(obj.var1, dictionary["var1"])
	_compare_simple_obj(obj.var2[0], dictionary["var2"][0])
	_compare_simple_obj(obj.var2[1], dictionary["var2"][1])
	_compare_simple_obj(obj.var3["key"], dictionary["var3"]["key"])

func _simple_object_dictionary() -> Dictionary:
	return {
			"Scrypt": SimpleObject,
			"var1": 1,
			"var2": 1.0,
			"var3": true,
			"var4": "String",
			"var5": Vector2.ONE,
			"var6":  [1, 2],
			"var7": {"key": 1}
			}

func _compare_simple_obj(obj:SimpleObject, dictionary:Dictionary) -> void:
	assert_eq(obj.var1, dictionary["var1"])
	assert_eq(obj.var2, dictionary["var2"])
	assert_eq(obj.var3, dictionary["var3"])
	assert_eq(obj.var5, dictionary["var5"])	
	assert_eq_deep(obj.var6, dictionary["var6"])
	assert_eq_deep(obj.var7, dictionary["var7"])
