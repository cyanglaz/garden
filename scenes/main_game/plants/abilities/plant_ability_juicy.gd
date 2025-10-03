class_name PlantAbilityJuicy
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType) -> bool:
	return ability_type == Plant.AbilityType.HARVEST

func _trigger_ability_hook(ability_type:Plant.AbilityType, main_game:MainGame, _plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.HARVEST)
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("water_cache").get_duplicate()
	var from_position:Vector2 = Util.get_node_ui_position(main_game.gui_main_game.gui_tool_card_container, self) - GUIToolCardButton.SIZE / 2
	await main_game.tool_manager.add_temp_tools_to_hand([tool_data], from_position, true)
