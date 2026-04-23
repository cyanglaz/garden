class_name FieldStatusContainer
extends Node2D

const FIELD_STATUS_SCENE_PREFIX := "res://scenes/main_game/combat/fields/status/field_status_%s.tscn"

signal status_updated()
signal request_status_hook_animation(status_id:String)
signal request_hook_message_popup(status_data:StatusData)

func setup_with_plant(plant:Plant) -> void:
	for field_status_id:String in plant.data.initial_field_status.keys():
		var stack:int = (plant.data.initial_field_status[field_status_id] as int)
		update_status(field_status_id, stack, plant)

func clear_status_on_turn_end() -> void:
	for field_status:FieldStatus in get_active_statuses():
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
		if stack <= 0:
			return
		var field_status_scene:PackedScene = load(FIELD_STATUS_SCENE_PREFIX % status_id)
		field_status = field_status_scene.instantiate()
		add_child(field_status)
		field_status.status_data = status_data
		field_status.stack = stack
		field_status.request_icon_animation.connect(_on_request_icon_animation)
		field_status.triggered.connect(_on_field_status_triggered.bind(field_status))
	if field_status.stack > 0:
		field_status.update_for_plant(plant)
	else:
		_remove_field_status(field_status)
	status_updated.emit()

func get_status_stack(status_id:String) -> int:
	var field_status:FieldStatus = _get_field_status(status_id)
	if field_status:
		return field_status.stack
	return 0

func clear_status(status_id:String) -> void:
	var field_status:FieldStatus = _get_field_status(status_id)
	if field_status:
		_remove_field_status(field_status)
	status_updated.emit()

func signal_bloom() -> void:
	for field_status:FieldStatus in get_children():
		field_status.active = false
	status_updated.emit()

func get_active_statuses() -> Array:
	var statuses:Array = get_children().filter(func(field_status:FieldStatus) -> bool:
		return field_status.active
	)
	statuses.reverse()
	return statuses

func queue_tool_application_hooks(plant:Plant) -> void:
	var tool_application_queue:Array = get_active_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_tool_application_hook(plant)
	)
	tool_application_queue.reverse()
	for field_status:FieldStatus in tool_application_queue:
		field_status.queue_tool_application_hook(plant)

func queue_tool_discard_hooks(plant:Plant, count:int) -> void:
	var tool_discard_queue:Array = get_active_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_tool_discard_hook(count, plant)
	)
	tool_discard_queue.reverse()
	for field_status:FieldStatus in tool_discard_queue:
		field_status.queue_tool_discard_hook(plant, count)

func queue_end_turn_hooks(plant:Plant) -> void:
	var end_turn_statuses:Array = get_active_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_end_turn_hook(plant)
	)
	end_turn_statuses.reverse()
	for field_status:FieldStatus in end_turn_statuses:
		field_status.handle_end_turn_hook(plant)

func queue_add_water_hooks(plant:Plant) -> void:
	var add_water_statuses:Array = get_active_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_add_water_hook(plant)
	)
	add_water_statuses.reverse()
	for field_status:FieldStatus in add_water_statuses:
		field_status.queue_add_water_hook(plant)

func handle_prevent_resource_update_value_hook(resource_id:String, plant:Plant, old_value:int, new_value:int) -> bool:
	var prevent_resource_update_value_statuses:Array = get_active_statuses().filter(func(field_status:FieldStatus) -> bool:
		return field_status.has_prevent_resource_update_value_hook(resource_id, plant, old_value, new_value)
	)
	for field_status:FieldStatus in prevent_resource_update_value_statuses:
		if field_status.handle_prevent_resource_update_value_hook(resource_id, plant, old_value, new_value):
			return true
	return false

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

func _on_request_icon_animation(field_status_data:StatusData) -> void:
	_send_hook_animation_signals(field_status_data)

func _on_field_status_triggered(field_status:FieldStatus) -> void:
	_handle_status_on_trigger(field_status)
