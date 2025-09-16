class_name PowerScriptSustainability
extends PowerScript

func _has_activation_hook(main_game:MainGame) -> bool:
	return _find_graywaters(main_game.tool_manager.deck.hand).size() > 0

func _has_card_added_to_hand_hook(tool_datas:Array[ToolData]) -> bool:
	return _find_graywaters(tool_datas).size() > 0
	
func _handle_activation_hook(main_game:MainGame) -> void:
	_update_cards(main_game.tool_manager.deck.hand)

func _handle_card_added_to_hand_hook(tool_datas:Array[ToolData]) -> void:
	_update_cards(tool_datas)

func _update_cards(tool_datas:Array[ToolData]) -> void:
	var gray_waters:Array = _find_graywaters(tool_datas)
	var old_modifier:int = power_data.data["sustainability"] as int if power_data.data.has("sustainability") else 0
	var new_modifier:int = power_data.stack
	for gray_water_data:ToolData in gray_waters:
		var water_action:ActionData = gray_water_data.actions[0]
		assert(water_action.type == ActionData.ActionType.WATER)
		water_action.value += new_modifier - old_modifier

func _find_graywaters(tool_datas:Array[ToolData]) -> Array:
	var gray_waters:Array = tool_datas.filter(func(tool_data:ToolData) -> bool:
		return tool_data.id == "graywater"
	)
	return gray_waters
