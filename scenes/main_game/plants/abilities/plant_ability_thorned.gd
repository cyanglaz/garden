class_name PlantAbilityThorn
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.END_TURN

func _trigger_ability_hook(ability_type:Plant.AbilityType, _plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.END_TURN)
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("thorn").get_duplicate()
	var from_position:Vector2 = Util.get_node_canvas_position(self) - GUICardFace.SIZE / 2
	Events.request_add_tools_to_discard_pile.emit([tool_data], from_position, true)
	await tool_data.adding_to_deck_finished
