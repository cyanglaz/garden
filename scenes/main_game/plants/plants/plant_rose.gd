class_name PlantRose
extends Plant

func _has_ability(ability_type:AbilityType) -> bool:
	return ability_type == AbilityType.HARVEST

func _trigger_ability(ability_type:AbilityType, main_game:MainGame) -> void:
	assert(ability_type == AbilityType.HARVEST)
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("thorn").get_duplicate()
	await main_game.tool_manager.add_tool_to_draw_pile(tool_data, Util.get_node_ui_position(main_game.gui_main_game.gui_tool_card_container, self), true, true)
	ability_triggered.emit(ability_type)
