class_name PlantAbilityJuicy
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.BLOOM

func _trigger_ability_hook(ability_type:Plant.AbilityType, _plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.BLOOM)
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("runoff").get_duplicate()
	#var from_position:Vector2 = global_position - GUICardFace.SIZE / 2
	var from_position:Vector2 = get_global_transform_with_canvas().origin - GUICardFace.SIZE / 2
	var tool_datas := []
	var last_tool_data:ToolData
	for i in stack:
		last_tool_data = tool_data.get_duplicate()
		tool_datas.append(last_tool_data)
	Events.request_add_tools_to_hand.emit(tool_datas, from_position, true)
	await last_tool_data.adding_to_deck_finished
