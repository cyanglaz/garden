class_name FieldStatusCurse
extends FieldStatus

var _turn_count:int = 0

func _has_end_turn_hook(plant:Plant) -> bool:
	return plant != null

func _handle_end_turn_hook(_combat_main:CombatMain, plant:Plant) -> void:
	var every_turn_count:int = status_data.data["turn"].to_int()
	if _turn_count % every_turn_count != 0:
		_turn_count += 1
		return
	_turn_count = 0
	Util.remove_all_children(self)
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("curse").get_duplicate()
	var from_position:Vector2 = Util.get_node_canvas_position(plant) - GUIToolCardButton.SIZE / 2
	
	var tool_data_to_add:ToolData = tool_data.get_duplicate()
	var hp_action:ActionData = tool_data_to_add.actions.front()
	assert(hp_action != null && hp_action.type == ActionData.ActionType.UPDATE_HP, "Curse must have an UPDATE_HP action")
	hp_action.value = -stack
	tool_data_to_add.name_postfix = "(" + str(stack) + ")"
	Events.request_add_tools_to_hand.emit([tool_data_to_add], from_position, true)
	await tool_data_to_add.adding_to_deck_finished
