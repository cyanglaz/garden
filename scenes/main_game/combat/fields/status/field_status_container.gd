class_name FieldStatusContainer
extends Node2D

const FIELD_STATUS_SCENE_PREFIX := "res://scenes/main_game/combat/fields/status/field_status_%s.tscn"

signal status_updated()
signal request_status_hook_animation(status_id:String)
signal request_hook_message_popup(status_data:StatusData)

var _bloom_hook_queue:Array = []
var _current_bloom_hook_index:int = 0
var _ability_hook_queue:Array = []
var _current_ability_hook_index:int = 0
var _tool_application_hook_queue:Array = []
var _current_tool_application_hook_index:int = 0
var _tool_discard_hook_queue:Array = []
var _current_tool_discard_hook_index:int = 0
var _end_turn_hook_queue:Array = []
var _current_end_turn_hook_index:int = 0
var _add_water_hook_queue:Array = []
var _current_add_water_hook_index:int = 0
var _prevent_resource_update_value_hook_queue:Array = []
var _current_prevent_resource_update_value_hook_index:int = 0

func setup_with_plant(plant:Plant) -> void:
	for field_status_id:String in plant.data.initial_field_status.keys():
		var stack:int = (plant.data.initial_field_status[field_status_id] as int)
		update_status(field_status_id, stack, plant)

func clear_status_on_turn_end() -> void:
	for field_status:FieldStatus in get_all_statuses():
		if field_status.status_data.reduce_stack_on_turn_end:
			field_status.stack -= 1
			if field_status.stack <= 0:
				_remove_field_status(field_status)
		if field_status.status_data.single_turn:
			_remove_field_status(field_status)
	status_updated.emit()

func update_status(status_id:String, stack:int, plant:Plant) -> void:
	var status_data := MainDatabase.field_status_database.get_data_by_id(status_id, true)
	var field_status:FieldStatus = _get_field_status(status_id)
	if field_status:
		field_status.stack += stack
	else:
		var field_status_scene:PackedScene = load(FIELD_STATUS_SCENE_PREFIX % status_id)
		field_status = field_status_scene.instantiate()
		add_child(field_status)
		field_status.status_data = status_data
		field_status.stack = stack
	if field_status.stack > 0:
		field_status.update_for_plant(plant)
	else:
		_remove_field_status(field_status)
	status_updated.emit()

func clear_status(status_id:String) -> void:
	var field_status:FieldStatus = _get_field_status(status_id)
	if field_status:
		_remove_field_status(field_status)
	status_updated.emit()

func clear_all_statuses() -> void:
	for field_status:FieldStatus in get_all_statuses():
		_remove_field_status(field_status)
	status_updated.emit()

func get_all_statuses() -> Array:
	var statuses:Array = get_children().duplicate()
	statuses.reverse()
	return statuses

func handle_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> void:
	_ability_hook_queue = get_all_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_ability_hook(ability_type, plant)
	)
	_current_ability_hook_index = 0
	await _handle_next_ability_hook(ability_type, plant)

func _handle_next_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> void:
	if _current_ability_hook_index >= _ability_hook_queue.size():
		return
	var field_status:FieldStatus = _ability_hook_queue[_current_ability_hook_index]
	_current_ability_hook_index += 1
	await _send_hook_animation_signals(field_status.status_data)
	await field_status.handle_ability_hook(ability_type, plant)
	await _handle_next_ability_hook(ability_type, plant)

func handle_bloom_hook(plant:Plant) -> void:
	_bloom_hook_queue = get_all_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_bloom_hook(plant)
	)
	_current_bloom_hook_index = 0
	await _handle_next_bloom_hook(plant)

func _handle_next_bloom_hook(plant:Plant) -> void:
	if _current_bloom_hook_index >= _bloom_hook_queue.size():
		return
	var field_status:FieldStatus = _bloom_hook_queue[_current_bloom_hook_index]
	await _send_hook_animation_signals(field_status.status_data)
	await field_status.handle_bloom_hook(plant)
	_handle_status_on_trigger(field_status)
	_current_bloom_hook_index += 1
	await _handle_next_bloom_hook(plant)

func handle_tool_application_hook(plant:Plant) -> void:
	_tool_application_hook_queue = get_all_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_tool_application_hook(plant)
	)
	_current_tool_application_hook_index = 0
	await _handle_next_tool_application_hook(plant)

func _handle_next_tool_application_hook(plant:Plant) -> void:
	if _current_tool_application_hook_index >= _tool_application_hook_queue.size():
		return
	var field_status:FieldStatus = _tool_application_hook_queue[_current_tool_application_hook_index]
	await _send_hook_animation_signals(field_status.status_data)
	await field_status.handle_tool_application_hook(plant)
	_handle_status_on_trigger(field_status)
	_current_tool_application_hook_index += 1
	await _handle_next_tool_application_hook(plant)

func handle_tool_discard_hook(plant:Plant, count:int) -> void:
	_tool_discard_hook_queue = get_all_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_tool_discard_hook(count, plant)
	)
	_current_tool_discard_hook_index = 0
	await _handle_next_tool_discard_hook(plant, count)

func _handle_next_tool_discard_hook(plant:Plant, count:int) -> void:
	if _current_tool_discard_hook_index >= _tool_discard_hook_queue.size():
		return
	var field_status:FieldStatus = _tool_discard_hook_queue[_current_tool_discard_hook_index]
	await _send_hook_animation_signals(field_status.status_data)
	await field_status.handle_tool_discard_hook(plant, count)
	_handle_status_on_trigger(field_status)
	_current_tool_discard_hook_index += 1
	await _handle_next_tool_discard_hook(plant, count)

func handle_end_turn_hook(combat_main:CombatMain, plant:Plant) -> void:
	_end_turn_hook_queue = get_all_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_end_turn_hook(plant)
	)
	_current_end_turn_hook_index = 0
	await _handle_next_end_turn_hook(combat_main, plant)

func _handle_next_end_turn_hook(combat_main:CombatMain, plant:Plant) -> void:
	if _current_end_turn_hook_index >= _end_turn_hook_queue.size():
		return
	var field_status:FieldStatus = _end_turn_hook_queue[_current_end_turn_hook_index]
	await _send_hook_animation_signals(field_status.status_data)
	await field_status.handle_end_turn_hook(combat_main, plant)
	_handle_status_on_trigger(field_status)
	_current_end_turn_hook_index += 1
	await _handle_next_end_turn_hook(combat_main, plant)

func handle_add_water_hook(plant:Plant) -> void:
	var all_statuses:Array = get_all_statuses()
	all_statuses.reverse()
	_add_water_hook_queue = all_statuses.filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_add_water_hook(plant)
	)
	_current_add_water_hook_index = 0
	await _handle_next_add_water_hook(plant)

func _handle_next_add_water_hook(plant:Plant) -> void:
	if _current_add_water_hook_index >= _add_water_hook_queue.size():
		return
	var field_status:FieldStatus = _add_water_hook_queue[_current_add_water_hook_index]
	await _send_hook_animation_signals(field_status.status_data)
	await field_status.handle_add_water_hook(plant)
	_handle_status_on_trigger(field_status)  
	_current_add_water_hook_index += 1
	await _handle_next_add_water_hook(plant)

func handle_prevent_resource_update_value_hook(resource_id:String, plant:Plant, old_value:int, new_value:int) -> bool:
	_prevent_resource_update_value_hook_queue = get_all_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_prevent_resource_update_value_hook(resource_id, plant, old_value, new_value)
	)
	_current_prevent_resource_update_value_hook_index = 0
	return await _handle_next_prevent_resource_update_value_hook(resource_id, plant, old_value, new_value)

func _handle_next_prevent_resource_update_value_hook(resource_id:String, plant:Plant, old_value:int, new_value:int) -> bool:
	if _current_prevent_resource_update_value_hook_index >= _prevent_resource_update_value_hook_queue.size():
		return false
	var field_status:FieldStatus = _prevent_resource_update_value_hook_queue[_current_prevent_resource_update_value_hook_index]
	await _send_hook_animation_signals(field_status.status_data)
	var prevent_resource_update_value:bool = field_status.handle_prevent_resource_update_value_hook(resource_id, plant, old_value, new_value)
	if prevent_resource_update_value:
		_handle_status_on_trigger(field_status)
		return true
	_current_prevent_resource_update_value_hook_index += 1
	return await _handle_next_prevent_resource_update_value_hook(resource_id, plant, old_value, new_value)

func _send_hook_animation_signals(status_data:StatusData) -> void:
	request_status_hook_animation.emit(status_data.id)
	request_hook_message_popup.emit(status_data)
	await Util.create_scaled_timer(Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION).timeout

func _handle_status_on_trigger(field_status:FieldStatus) -> void:
	if field_status.status_data.reduce_stack_on_trigger:
		field_status.stack -= 1
	if field_status.status_data.remove_on_trigger:
		field_status.stack = 0
	if field_status.stack <= 0:
		_remove_field_status(field_status)
	status_updated.emit()

func _remove_field_status(field_status:FieldStatus) -> void:
	remove_child(field_status)
	field_status.queue_free()

func _get_field_status(status_id:String) -> FieldStatus:
	for field_status:FieldStatus in get_children():
		if field_status.status_data.id == status_id:
			return field_status
	return null
