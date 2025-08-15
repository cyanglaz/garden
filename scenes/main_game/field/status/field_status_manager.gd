class_name FieldStatusManager
extends RefCounted

signal status_updated()
signal request_status_hook_animation(status_id:String)
signal request_hook_message_popup(status_data:FieldStatusData)

var field_status_map:Dictionary[String, FieldStatusData]

var _harvest_gold_hook_queue:Array[String] = []
var _current_harvest_gold_hook_index:int = 0
var _ability_hook_queue:Array[String] = []
var _current_ability_hook_index:int = 0
var _tool_application_hook_queue:Array[String] = []
var _current_tool_application_hook_index:int = 0

func handle_status_on_turn_end() -> void:
	for status_id in field_status_map.keys():
		var status_data:FieldStatusData = field_status_map[status_id]
		if status_data.reduce_stack_on_turn_end:
			status_data.stack -= 1
			if status_data.stack <= 0:
				field_status_map.erase(status_id)
		if status_data.single_turn:
			field_status_map.erase(status_id)
	status_updated.emit()

func update_status(status_id:String, stack:int) -> void:
	var status_data := MainDatabase.field_status_database.get_data_by_id(status_id)
	if field_status_map.has(status_id):
		field_status_map[status_id].stack += stack
	else:
		field_status_map[status_id] = status_data
		field_status_map[status_id].stack = stack
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

func handle_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> FieldStatusScript.HookResultType:
	var all_status_ids := field_status_map.keys()
	_ability_hook_queue = all_status_ids.filter(func(status_id:String) -> bool:
		return field_status_map[status_id].status_script.has_ability_hook(ability_type, plant)
	)
	_current_ability_hook_index = 0
	return await _handle_next_ability_hook(ability_type, plant, FieldStatusScript.HookResultType.PASS)

func _handle_next_ability_hook(ability_type:Plant.AbilityType, plant:Plant, final_result_type:FieldStatusScript.HookResultType) -> FieldStatusScript.HookResultType:
	if _current_ability_hook_index >= _ability_hook_queue.size():
		return final_result_type
	var status_id:String = _ability_hook_queue[_current_ability_hook_index]
	var status_data := field_status_map[status_id]
	await _send_hook_animation_signals(status_data)
	var hook_result := await status_data.status_script.handle_ability_hook(ability_type, plant)
	if hook_result == FieldStatusScript.HookResultType.ABORT:
		final_result_type = hook_result
	_current_ability_hook_index += 1
	return await _handle_next_ability_hook(ability_type, plant, final_result_type)

func handle_harvest_gold_hooks(plant:Plant) -> void:
	var all_status_ids := field_status_map.keys()
	_harvest_gold_hook_queue = all_status_ids.filter(func(status_id:String) -> bool:
		return field_status_map[status_id].status_script.has_harvest_gold_hook()
	)
	_current_harvest_gold_hook_index = 0
	await _handle_next_harvest_gold_hook(plant)

func _handle_next_harvest_gold_hook(plant:Plant) -> void:
	if _current_harvest_gold_hook_index >= _harvest_gold_hook_queue.size():
		return
	var status_id:String = _harvest_gold_hook_queue[_current_harvest_gold_hook_index]
	var status_data := field_status_map[status_id]
	await _send_hook_animation_signals(status_data)
	await status_data.status_script.handle_harvest_gold_hook(plant)
	_current_harvest_gold_hook_index += 1
	await _handle_next_harvest_gold_hook(plant)

func handle_tool_application_hook(plant:Plant) -> void:
	var all_status_ids := field_status_map.keys()
	_tool_application_hook_queue = all_status_ids.filter(func(status_id:String) -> bool:
		return field_status_map[status_id].status_script.has_tool_application_hook()
	)
	_current_tool_application_hook_index = 0
	await _handle_next_tool_application_hook(plant)

func _handle_next_tool_application_hook(plant:Plant) -> void:
	if _current_tool_application_hook_index >= _tool_application_hook_queue.size():
		return
	var status_id:String = _tool_application_hook_queue[_current_tool_application_hook_index]
	var status_data := field_status_map[status_id]
	await _send_hook_animation_signals(status_data)
	await status_data.status_script.handle_tool_application_hook(plant)
	_current_tool_application_hook_index += 1
	await _handle_next_tool_application_hook(plant)

func _send_hook_animation_signals(status_data:FieldStatusData) -> void:
	request_status_hook_animation.emit(status_data.id)
	request_hook_message_popup.emit(status_data)
	await Util.create_scaled_timer(Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION).timeout
