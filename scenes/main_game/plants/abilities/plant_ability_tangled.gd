class_name PlantAbilityTangled
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _main_game:MainGame, _plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.HARVEST

func _trigger_ability_hook(ability_type:Plant.AbilityType, main_game:MainGame, _plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.HARVEST)
	for tool_data:ToolData in main_game.tool_manager.tool_deck.hand:
		tool_data.energy_modifier = tool_data.energy_cost
	main_game.tool_manager.refresh_ui()
