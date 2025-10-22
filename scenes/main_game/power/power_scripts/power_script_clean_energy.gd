class_name PowerScriptCleanEnergy
extends PowerScript

var _action_count := 0
signal _all_action_application_completed()

func _has_tool_application_hook(_combat_main:CombatMain, tool_data:ToolData) -> bool:
	return tool_data.energy_cost == 0

func _handle_tool_application_hook(combat_main:CombatMain, _tool_data:ToolData) -> void:
	var action_data:ActionData = ActionData.new()
	action_data.type = ActionData.ActionType.LIGHT
	action_data.value = power_data.stack
	action_data.specials.append(ActionData.Special.ALL_FIELDS)
	_action_count = combat_main.field_container.fields.size()
	assert(_action_count > 0)
	for field:Field in combat_main.field_container.fields:
		field.action_application_completed.connect(_on_action_application_completed.bind(field))
		field.apply_actions([action_data], null)
	await _all_action_application_completed

func _on_action_application_completed(field:Field) -> void:
	field.action_application_completed.disconnect(_on_action_application_completed.bind(field))
	_action_count -= 1
	if _action_count == 0:
		_all_action_application_completed.emit()
