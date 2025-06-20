class_name Snapshot
extends RefCounted

# signal about_to_restore_property(name:String, value:Variant)
@warning_ignore("unused_signal")
signal restored()

var save_data:Dictionary

var _obj:Object : get = _get_obj
var _weak_obj:WeakRef
var _properties_to_save:Array[String]

func _init(obj:Object, properties_to_save:Array[String]) -> void:
	_weak_obj = weakref(obj)
	_properties_to_save = properties_to_save

func add_properties_to_watch(properties:Array[String], insert_front:bool = false) -> void:
	if insert_front:
		for property_name in properties:
			_properties_to_save.push_front(property_name)
	else:
		_properties_to_save.append_array(properties)
	
func save() -> Dictionary:
	var new_save_data = {}
	save_data = new_save_data
	save_data["Scrypt"] = _get_script_by_name((_obj.get_script() as GDScript).get_global_name())
	if _obj is Resource:
		if  (_obj as Resource).get("_original_resource_path"):
			save_data["ResourcePath"] = (_obj as Resource).get("_original_resource_path")
		elif !(_obj as Resource).resource_path.is_empty():
			save_data["ResourcePath"] = (_obj as Resource).resource_path
	for key in _properties_to_save:
		var value = _obj.get(key)
		save_data[key] = _recursive_save(value)
	return save_data

#region save helpers
func _recursive_save(variant:Variant) -> Variant:
	if variant is Object:
		return _save_object(variant)
	elif variant is Array:
		return _save_array(variant)
	elif variant is Dictionary:
		return _save_dictionary(variant)
	else:
		return variant

func _save_array(array:Array) -> Array:
	var result_array := []
	for variant:Variant in array:
		result_array.append(_recursive_save(variant))
	return result_array
	
func _save_dictionary(dictionary:Dictionary) -> Dictionary:
	var result_dictionary := {}
	for key in dictionary.keys():
		var variant = dictionary[key]
		result_dictionary[key] = _recursive_save(variant)
	return result_dictionary

func _save_object(obj:Object) -> Dictionary:
	var obj_snapshot:Snapshot = obj.get("_snapshot")
	if obj_snapshot:
		return obj_snapshot.save()
	return {}

#endregion
	
func _get_obj() -> Object:
	return _weak_obj.get_ref()

#region load

func load_self_save(data:Dictionary = {}) -> void:
	if data.is_empty():
		data = save_data
	for key in _properties_to_save:
		var value = Snapshot._recursive_load(data[key])
		_obj.set(key, value)

static func load_save(data:Dictionary) -> Object:
	var obj
	if data.has("ResourcePath"):
		var resourece_path = data["ResourcePath"]
		obj = load(resourece_path).get_duplicate()
	else:
		var scrypt = data["Scrypt"]
		obj = (scrypt as GDScript).new()
	for key in data:
		if key == "Scrypt":
			continue
		var value = data[key]
		var loaded_value = _recursive_load(value)
		obj.set(key, loaded_value)
	obj._snapshot.restored.emit()
	obj._snapshot.save_data = data.duplicate()
	return obj

#endreigon

#region load helpers
static func _recursive_load(variant:Variant) -> Variant:
	if variant is Array:
		return _load_array(variant)
	elif variant is Dictionary:
		return _load_dictionary(variant)
	else:
		return variant

static func _load_array(array:Array) -> Array:
	var result := []
	for value in array:
		var loaded_value = _recursive_load(value)
		result.append(loaded_value)
	return result

static func _load_dictionary(dictionary:Dictionary) -> Variant:
	if dictionary.has("Scrypt"):
		# The directionay represents an objct.
		return load_save(dictionary)
	else:
		var result := {}
		for key in dictionary:
			result[key] = _recursive_load(dictionary[key])
		return result
#endregion

#region scrypt name helper

static func _get_script_by_name(name_of_class:String) -> Script:
	if ResourceLoader.exists(name_of_class, "Script"):
		return load(name_of_class) as Script

	for global_class in ProjectSettings.get_global_class_list():
		var found_name_of_class:String = global_class["class"]
		var found_path:String = global_class["path"]
		if found_name_of_class == name_of_class:
			return load(found_path) as Script

	return null

#endregion
