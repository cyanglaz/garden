class_name WeatherActionApplier
extends RefCounted

signal action_application_completed()

func apply_action(action:ActionData, combat_main:CombatMain) -> void:
	assert(action.action_category == ActionData.ActionCategory.WEATHER)
	var from_position := combat_main.gui.gui_tool_card_container.get_center_position()
	await combat_main.weather_main.apply_weather_tool_action(action, from_position, combat_main)
	action_application_completed.emit()
