class_name ToolScriptNullZone
extends ToolScript

func apply_tool(combat_main: CombatMain, _tool_data: ToolData, _secondary_card_datas: Array) -> void:
	var field_index := combat_main.player.current_field_index
	combat_main.weather_main.remove_weather_ability_at_field_index(field_index)
	await Util.await_for_tiny_time()
