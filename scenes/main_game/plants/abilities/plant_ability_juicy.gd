class_name PlantAbilityJuicy
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _combat_main:CombatMain, plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.START_TURN && plant.is_bloom()

func _trigger_ability_hook(ability_type:Plant.AbilityType, combat_main:CombatMain, _plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.START_TURN)
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("water_cache").get_duplicate()
	#var from_position:Vector2 = global_position - GUIToolCardButton.SIZE / 2
	var from_position:Vector2 = get_global_transform_with_canvas().origin - GUIToolCardButton.SIZE / 2
	await combat_main.add_tools_to_hand([tool_data], from_position, true)
