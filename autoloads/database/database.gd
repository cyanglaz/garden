class_name Database
extends Node

var _datas:Dictionary

func _ready() -> void:
	_load_db()
	
func get_all_datas() -> Array:
	return _datas.values()

func get_data_by_id(id:String, copy:bool=false) -> Resource:
	var original_data = _datas[id]
	if !copy:
		return original_data
	var new_data:Resource = original_data.get_duplicate()
	return new_data

func _load_db() -> void:
	_load_data_from_dir(_get_data_dir())
	
func _load_data_from_dir(dir_path:String):
	assert(DirAccess.dir_exists_absolute(dir_path))
	var all_resource_files := Util.get_all_file_paths(dir_path, true)
	for file_path in all_resource_files:
		var resource := load(file_path)
		_datas[resource.id] = resource

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_datas.clear()

func _get_data_dir() -> String:
	return ""
