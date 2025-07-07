class_name FieldStatusManager
extends RefCounted

signal status_updated()
signal request_status_hook_animation(status_id:String)

var field_status_map:Dictionary[String, FieldStatusData]

var _harvest_ability_hook_queue:Array[String] = []
var _current_harvest_ability_hook_index:int = 0

func add_status(status_id:String, stack:int) -> void:
	var status_data := MainDatabase.field_status_database.get_data_by_id(status_id)
	if field_status_map.has(status_id):
		field_status_map[status_id].stack += stack
	else:
		field_status_map[status_id] = status_data
	status_updated.emit()

func remove_status(status_id:String, stack:int) -> void:
	field_status_map[status_id].stack -= stack
	if field_status_map[status_id].stack <= 0:
		field_status_map.erase(status_id)
	status_updated.emit()

func clear_status(status_id:String) -> void:
	field_status_map.erase(status_id)
	status_updated.emit()

func clear_all_statuses() -> void:
	field_status_map.clear()
	status_updated.emit()

func get_status(status_id:String) -> FieldStatusData:
	return field_status_map[status_id]

func get_all_statuses() -> Array[FieldStatusData]:
	return field_status_map.values()

func handle_harvest_ability_hooks(plant:Plant) -> FieldStatusScript.HookResultType:
	var all_status_ids := field_status_map.keys()
	_harvest_ability_hook_queue = all_status_ids.filter(func(status_id:String) -> bool:
		return field_status_map[status_id].status_script.has_harvest_hook()
	)
	_current_harvest_ability_hook_index = 0
	return await _handle_next_harvest_ability_hook(plant, FieldStatusScript.HookResultType.PASS)

func _handle_next_harvest_ability_hook(plant:Plant, result_type:FieldStatusScript.HookResultType) -> FieldStatusScript.HookResultType:
	if _current_harvest_ability_hook_index >= _harvest_ability_hook_queue.size():
		return result_type
	var status_id:String = _harvest_ability_hook_queue[_current_harvest_ability_hook_index]
	request_status_hook_animation.emit(status_id)
	await Util.create_scaled_timer(Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION).timeout
	var status_data := field_status_map[status_id]
	var hook_result := status_data.status_script.handle_harvest_ability_hook(plant)
	var final_hook_result := result_type
	if hook_result == FieldStatusScript.HookResultType.ABORT:
		final_hook_result = FieldStatusScript.HookResultType.ABORT
	_current_harvest_ability_hook_index += 1
	return await _handle_next_harvest_ability_hook(plant, final_hook_result)
