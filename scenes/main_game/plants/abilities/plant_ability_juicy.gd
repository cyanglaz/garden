class_name PlantAbilityJuicy
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.BLOOM

func _trigger_ability_hook(ability_type:Plant.AbilityType, _plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.BLOOM)
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("water_cache").get_duplicate()
	#var from_position:Vector2 = global_position - GUIToolCardButton.SIZE / 2
	var from_position:Vector2 = get_global_transform_with_canvas().origin - GUIToolCardButton.SIZE / 2
	Events.request_add_tools_to_hand.emit([tool_data], from_position, true)
	await tool_data.adding_to_deck_finished
