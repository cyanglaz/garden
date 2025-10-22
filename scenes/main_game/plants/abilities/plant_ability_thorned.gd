class_name PlantAbilityThorn
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _combat_main:CombatMain, _plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.HARVEST

func _trigger_ability_hook(ability_type:Plant.AbilityType, combat_main:CombatMain, _plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.HARVEST)
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("thorn").get_duplicate()
	var from_position:Vector2 = Util.get_node_ui_position(combat_main.gui.gui_tool_card_container, self) - GUIToolCardButton.SIZE / 2
	await combat_main.tool_manager.add_temp_tools_to_discard_pile([tool_data], from_position, true)
