class_name FieldStatusManager
extends RefCounted

signal status_updated()
signal request_status_hook_animation(status_id:String)
signal request_hook_message_popup(status_data:FieldStatusData)

var field_status_map:Dictionary[String, FieldStatusData]

var _harvest_hook_queue:Array[String] = []
var _current_harvest_hook_index:int = 0
var _ability_hook_queue:Array[String] = []
var _current_ability_hook_index:int = 0
var _tool_application_hook_queue:Array[String] = []
var _current_tool_application_hook_index:int = 0
var _tool_discard_hook_queue:Array[String] = []
var _current_tool_discard_hook_index:int = 0
var _end_day_hook_queue:Array[String] = []
var _current_end_day_hook_index:int = 0
var _add_water_hook_queue:Array[String] = []
var _current_add_water_hook_index:int = 0

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
	var status_data := MainDatabase.field_status_database.get_data_by_id(status_id, true)
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

func handle_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> void:
	var all_status_ids := field_status_map.keys()
	_ability_hook_queue = all_status_ids.filter(func(status_id:String) -> bool:
		return field_status_map[status_id].status_script.has_ability_hook(ability_type, plant)
	)
	_current_ability_hook_index = 0
	await _handle_next_ability_hook(ability_type, plant)

func _handle_next_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> void:
	if _current_ability_hook_index >= _ability_hook_queue.size():
		return
	var status_id:String = _ability_hook_queue[_current_ability_hook_index]
	_current_ability_hook_index += 1
	var status_data := field_status_map[status_id]
	await _send_hook_animation_signals(status_data)
	await status_data.status_script.handle_ability_hook(ability_type, plant)
	await _handle_next_ability_hook(ability_type, plant)

func handle_harvest_hook(plant:Plant) -> void:
	var all_status_ids := field_status_map.keys()
	_harvest_hook_queue = all_status_ids.filter(func(status_id:String) -> bool:
		return field_status_map[status_id].status_script.has_harvest_hook(plant)
	)
	_current_harvest_hook_index = 0
	await _handle_next_harvest_hook(plant)

func _handle_next_harvest_hook(plant:Plant) -> void:
	if _current_harvest_hook_index >= _harvest_hook_queue.size():
		return
	var status_id:String = _harvest_hook_queue[_current_harvest_hook_index]
	var status_data := field_status_map[status_id]
	await _send_hook_animation_signals(status_data)
	await status_data.status_script.handle_harvest_hook(plant)
	_handle_status_on_trigger(status_data)
	_current_harvest_hook_index += 1
	await _handle_next_harvest_hook(plant)

func handle_tool_application_hook(plant:Plant) -> void:
	var all_status_ids := field_status_map.keys()
	_tool_application_hook_queue = all_status_ids.filter(func(status_id:String) -> bool:
		return field_status_map[status_id].status_script.has_tool_application_hook(plant)
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
	_handle_status_on_trigger(status_data)
	_current_tool_application_hook_index += 1
	await _handle_next_tool_application_hook(plant)

func handle_tool_discard_hook(plant:Plant, count:int) -> void:
	var all_status_ids := field_status_map.keys()
	_tool_discard_hook_queue = all_status_ids.filter(func(status_id:String) -> bool:
		return field_status_map[status_id].status_script.has_tool_discard_hook(count, plant)
	)
	_current_tool_discard_hook_index = 0
	await _handle_next_tool_discard_hook(plant, count)

func _handle_next_tool_discard_hook(plant:Plant, count:int) -> void:
	if _current_tool_discard_hook_index >= _tool_discard_hook_queue.size():
		return
	var status_id:String = _tool_discard_hook_queue[_current_tool_discard_hook_index]
	var status_data := field_status_map[status_id]
	await _send_hook_animation_signals(status_data)
	await status_data.status_script.handle_tool_discard_hook(plant, count)
	_handle_status_on_trigger(status_data)
	_current_tool_discard_hook_index += 1
	await _handle_next_tool_discard_hook(plant, count)

func handle_end_day_hook(main_game:MainGame, plant:Plant) -> void:
	var all_status_ids := field_status_map.keys()
	_end_day_hook_queue = all_status_ids.filter(func(status_id:String) -> bool:
		return field_status_map[status_id].status_script.has_end_day_hook(plant)
	)
	_current_end_day_hook_index = 0
	await _handle_next_end_day_hook(main_game, plant)

func _handle_next_end_day_hook(main_game:MainGame, plant:Plant) -> void:
	if _current_end_day_hook_index >= _end_day_hook_queue.size():
		return
	var status_id:String = _end_day_hook_queue[_current_end_day_hook_index]
	var status_data := field_status_map[status_id]
	await _send_hook_animation_signals(status_data)
	await status_data.status_script.handle_end_day_hook(main_game, plant)
	_handle_status_on_trigger(status_data)
	_current_end_day_hook_index += 1
	await _handle_next_end_day_hook(main_game, plant)

func handle_add_water_hook(plant:Plant) -> void:
	var all_status_ids := field_status_map.keys()
	_add_water_hook_queue = all_status_ids.filter(func(status_id:String) -> bool:
		return field_status_map[status_id].status_script.has_add_water_hook(plant)
	)
	_current_add_water_hook_index = 0
	await _handle_next_add_water_hook(plant)

func _handle_next_add_water_hook(plant:Plant) -> void:
	if _current_add_water_hook_index >= _add_water_hook_queue.size():
		return
	var status_id:String = _add_water_hook_queue[_current_add_water_hook_index]
	var status_data := field_status_map[status_id]
	await _send_hook_animation_signals(status_data)
	await status_data.status_script.handle_add_water_hook(plant)
	_handle_status_on_trigger(status_data)
	_current_add_water_hook_index += 1
	await _handle_next_add_water_hook(plant)

func _send_hook_animation_signals(status_data:FieldStatusData) -> void:
	request_status_hook_animation.emit(status_data.id)
	request_hook_message_popup.emit(status_data)
	await Util.create_scaled_timer(Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION).timeout

func _handle_status_on_trigger(status_data:FieldStatusData) -> void:
	if status_data.reduce_stack_on_trigger:
		status_data.stack -= 1
	if status_data.remove_on_trigger:
		status_data.stack = 0
	if status_data.stack <= 0:
		field_status_map.erase(status_data.id)
	status_updated.emit()
