class_name SaveTestHelper

static func recursive_compare(gut_test:GutTest, obj1:Object, obj2:Object) -> void:
	for key in obj1._snapshot._properties_to_save:
		if obj1.get(key) is Object:
			recursive_compare(gut_test, obj1.get(key), obj2.get(key))
		elif obj1.get(key) is Dictionary:
			_compare_dictionary(gut_test, obj1.get(key), obj2.get(key))
		elif obj1.get(key) is Array:
			_comapre_array(gut_test, obj1.get(key), obj2.get(key))
		else:
			gut_test.assert_eq(obj1.get(key), obj2.get(key))

static func _compare_dictionary(gut_test, dictionary1:Dictionary, dictionary2:Dictionary) -> void:
	gut_test.assert_eq(dictionary1.size(), dictionary2.size())
	for key in dictionary1.keys():
		var var1 = dictionary1[key]
		var var2 = dictionary2[key]
		if var1 is Object:
			recursive_compare(gut_test, var1, var2)
		elif var1 is Dictionary:
			_compare_dictionary(gut_test, dictionary1, dictionary2)
		elif var1 is Array:
			_comapre_array(gut_test, var1, var2)
		else:
			gut_test.assert_eq(var1, var2)

static func _comapre_array(gut_test, array1:Array, array2:Array) -> void:
	gut_test.assert_eq(array1.size(), array2.size())
	for i in array1.size():
		var var1 = array1[i]
		var var2 = array2[i]
		if var1 is Object:
			recursive_compare(gut_test, var1, var2)
		elif var1 is Dictionary:
			_compare_dictionary(gut_test, var1, var2)
		elif var1 is Array:
			_comapre_array(gut_test, var1, var2)
		else:
			gut_test.assert_eq(var1, var2)
