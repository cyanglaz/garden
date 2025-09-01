class_name Database
extends Node

var _datas:Dictionary

func _ready() -> void:
	_load_db()
	
func get_all_datas() -> Array:
	return _get_all_resources(_datas, "").values()

func get_data_by_id(id:String, copy:bool=false) -> Resource:
	var all_datas = _get_all_resources(_datas, "")
	if !all_datas.has(id):
		return null
	var original_data = all_datas[id]
	if !copy:
		return original_data
	var new_data:Resource = original_data.get_duplicate()
	return new_data

func _load_db() -> void:
	_load_data_from_dir(_get_data_dir())
	
func _load_data_from_dir(dir_path:String):
	assert(DirAccess.dir_exists_absolute(dir_path))
	var all_resource_files := Util.get_all_file_paths(dir_path, true)
	for file_path:String in all_resource_files:
		var subdir_name := ""
		var relative_path := file_path.replace(dir_path + "/", "")
		var path_parts := relative_path.split("/")
		if path_parts.size() > 1:
			subdir_name = path_parts[0]
		var resource = ResourceLoader.load(file_path)
		_evaluate_data(resource)
		if subdir_name.is_empty():
			_datas[resource.id] = resource
		else:
			if !_datas.has(subdir_name):
				_datas[subdir_name] = {}
			_datas[subdir_name][resource.id] = resource

func _get_all_resources(data:Dictionary, category:String) -> Dictionary:
	if data.has(category):
		return _get_all_resources(data[category], "")
	var result:Dictionary
	for key in data.keys():
		var value = data[key]
		if value is Dictionary:
			result.merge(_get_all_resources(value, key))
		else:
			result[key] = value
	return result

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_datas.clear()
	
func _evaluate_data(_resource:Resource) -> void:
	pass

func _get_data_dir() -> String:
	return ""
