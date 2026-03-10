class_name PlayerStatusSustainability
extends PlayerStatus

func _has_activation_hook(combat_main:CombatMain) -> bool:
	return _find_runoffs(combat_main.tool_manager.tool_deck.hand).size() > 0

func _handle_activation_hook(combat_main:CombatMain) -> void:
	_update_cards(combat_main.tool_manager.tool_deck.hand)

func _has_card_added_to_hand_hook(tool_datas:Array) -> bool:
	return _find_runoffs(tool_datas).size() > 0

func _handle_card_added_to_hand_hook(tool_datas:Array) -> void:
	_update_cards(tool_datas)

func _update_cards(tool_datas:Array) -> void:
	var gray_waters:Array = _find_runoffs(tool_datas)
	var new_modifier:int = stack
	for gray_water_data:ToolData in gray_waters:
		var old_modifier:int = gray_water_data.data["sustainability"] as int if gray_water_data.data.has("sustainability") else 0
		gray_water_data.data["sustainability"] = new_modifier
		var water_action:ActionData = gray_water_data.actions[0]
		assert(water_action.type == ActionData.ActionType.WATER)
		var change := new_modifier - old_modifier
		water_action.modified_value += change
		gray_water_data.request_refresh.emit()

func _find_runoffs(tool_datas:Array) -> Array:
	var gray_waters:Array = tool_datas.filter(func(tool_data:ToolData) -> bool:
		return tool_data.id == "runoff"
	)
	print(gray_waters)
	return gray_waters
