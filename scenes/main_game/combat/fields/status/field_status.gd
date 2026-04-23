class_name FieldStatus
extends Node2D

@warning_ignore("unused_private_class_variable")
var status_data:StatusData
var stack:int:set = _set_stack, get = _get_stack
var active:bool = true

signal triggered()
signal request_icon_animation(status_data:StatusData)

func update_for_plant(plant:Plant) -> void:
	_update_for_plant(plant)

func has_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> bool:
	if not active:
		return false
	return _has_ability_hook(ability_type, plant)

func has_bloom_hook(plant:Plant) -> bool:
	if not active:
		return false
	return _has_bloom_hook(plant)

func has_add_water_hook(plant:Plant) -> bool:
	if not active:
		return false
	return _has_add_water_hook(plant)

func queue_add_water_hook(plant:Plant) -> void:
	var request = CombatQueueRequest.new()
	request.front = true
	request.callback = func(_combat_main:CombatMain) -> void: 
		if not active:
			return
		request_icon_animation.emit(status_data)
		await Util.create_scaled_timer(Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION).timeout
		await _handle_add_water_hook(plant)
		triggered.emit()
	Events.request_combat_queue_push.emit(request)

func has_tool_application_hook(plant:Plant) -> bool:
	if not active:
		return false
	return _has_tool_application_hook(plant)

func queue_tool_application_hook(plant:Plant) -> void:
	var request = CombatQueueRequest.new()
	request.front = true
	request.callback = func(combat_main:CombatMain) -> void: 
		if not active:
			return
		request_icon_animation.emit(status_data)
		await Util.create_scaled_timer(Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION).timeout
		await _handle_tool_application_hook(plant, combat_main)
		triggered.emit()
	Events.request_combat_queue_push.emit(request)

func has_tool_discard_hook(count:int, plant:Plant) -> bool:
	if not active:
		return false
	return _has_tool_discard_hook(count, plant)

func queue_tool_discard_hook(plant:Plant, count:int) -> void:
	var request = CombatQueueRequest.new()
	request.front = true
	request.callback = func(combat_main:CombatMain) -> void: 
		if not active:
			return
		request_icon_animation.emit(status_data)
		await Util.create_scaled_timer(Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION).timeout
		await _handle_tool_discard_hook(plant, count, combat_main)
		triggered.emit()
	Events.request_combat_queue_push.emit(request)

func has_end_turn_hook(plant:Plant) -> bool:
	if not active:
		return false
	return _has_end_turn_hook(plant)

func handle_end_turn_hook(plant:Plant) -> void:
	var request = CombatQueueRequest.new()
	request.callback = func(cm:CombatMain) -> void: 
		if not active:
			return
		request_icon_animation.emit(status_data)
		await Util.create_scaled_timer(Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION).timeout
		await _handle_end_turn_hook(cm, plant)
		triggered.emit()
	Events.request_combat_queue_push.emit(request)

func has_prevent_resource_update_value_hook(resource_id:String, plant:Plant, old_value:int, new_value:int) -> bool:
	if not active:
		return false
	return _has_prevent_resource_update_value_hook(resource_id, plant, old_value, new_value)

func handle_prevent_resource_update_value_hook(resource_id:String, plant:Plant, old_value:int, new_value:int) -> bool:
	if not active:
		return false
	return _handle_prevent_resource_update_value_hook(resource_id, plant, old_value, new_value)

#region for override

func _update_for_plant(_plant:Plant) -> void:
	pass

func _has_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant) -> bool:
	return false

func _has_bloom_hook(_plant:Plant) -> bool:
	return false

func _has_tool_application_hook(_plant:Plant) -> bool:
	return false

func _handle_tool_application_hook(_plant:Plant, _combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()
	
func _has_tool_discard_hook(_count:int, _plant:Plant) -> bool:
	return false

func _has_add_water_hook(_plant:Plant) -> bool:
	return false

func _handle_add_water_hook(_plant:Plant) -> void:
	await Util.await_for_tiny_time()

func _has_end_turn_hook(_plant:Plant) -> bool:
	return false

func _handle_end_turn_hook(_combat_main:CombatMain, _plant:Plant) -> void:
	await Util.await_for_tiny_time()

func _handle_tool_discard_hook(_plant:Plant, _count:int, _combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _has_prevent_resource_update_value_hook(_resource_id:String, _plant:Plant, _old_value:int, _new_value:int) -> bool:
	return false

func _handle_prevent_resource_update_value_hook(_resource_id:String, _plant:Plant, _old_value:int, _new_value:int) -> bool:
	return false

#endregion

func _set_stack(value:int) -> void:
	status_data.stack = value

func _get_stack() -> int:
	return status_data.stack
