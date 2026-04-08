class_name ToolScriptEnergyTransfer
extends ToolScript

func apply_tool(combat_main: CombatMain, _tool_data: ToolData, _secondary_card_datas: Array) -> void:
	var plant: Plant = combat_main.get_current_player_plant()

	var original_water: int = plant.water.value
	var original_light: int = plant.light.value

	var water_action: ActionData = ActionData.new()
	water_action.type = ActionData.ActionType.WATER
	water_action.operator_type = ActionData.OperatorType.EQUAL_TO
	water_action.value = original_light
	await plant.apply_actions([water_action])

	var light_action: ActionData = ActionData.new()
	light_action.type = ActionData.ActionType.LIGHT
	light_action.operator_type = ActionData.OperatorType.EQUAL_TO
	light_action.value = original_water
	await plant.apply_actions([light_action])

func need_select_field() -> bool:
	return true

func has_field_action() -> bool:
	return true
