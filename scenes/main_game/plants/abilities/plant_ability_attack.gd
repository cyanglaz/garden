class_name PlantAbilityAttack
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.START_TURN

func _trigger_ability_hook(_ability_type:Plant.AbilityType, plant:Plant) -> void:
	Util.remove_all_children(self)
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("damage").get_duplicate()
	var from_position:Vector2 = Util.get_node_canvas_position(plant) - GUICardFace.SIZE / 2
	
	var tool_data_to_add:ToolData = tool_data.get_duplicate()
	var hp_action:ActionData = tool_data_to_add.actions.front()
	assert(hp_action != null && hp_action.type == ActionData.ActionType.UPDATE_HP, "Damage must have an UPDATE_HP action")
	hp_action.value = stack
	hp_action.operator_type = ActionData.OperatorType.DECREASE
	tool_data_to_add.name_postfix = "(" + str(stack) + ")"
	Events.request_add_tools_to_hand.emit([tool_data_to_add], from_position, true)
	await tool_data_to_add.adding_to_deck_finished
