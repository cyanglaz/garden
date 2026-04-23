class_name PlayerStatusSustainability
extends PlayerStatus

func _has_activation_hook(combat_main:CombatMain) -> bool:
	return _find_free_waters(combat_main.tool_manager.tool_deck.pool).size() > 0

func _handle_activation_hook(combat_main:CombatMain) -> void:
	_update_cards(combat_main.tool_manager.tool_deck.pool, combat_main)

func _has_pool_updated_hook(_combat_main:CombatMain, pool:Array) -> bool:
	return _find_free_waters(pool).size() > 0

func _handle_pool_updated_hook(combat_main:CombatMain, pool:Array) -> void:
	_update_cards(pool, combat_main)

func _update_cards(pool:Array, combat_main:CombatMain) -> void:
	var gray_waters:Array = _find_free_waters(pool)
	var new_modifier:int = stack
	for gray_water_data:ToolData in gray_waters:
		var old_modifier:int = gray_water_data.data["sustainability"] as int if gray_water_data.data.has("sustainability") else 0
		gray_water_data.data["sustainability"] = new_modifier
		var water_action:ActionData = gray_water_data.actions[0]
		assert(water_action.type == ActionData.ActionType.WATER)
		var change := new_modifier - old_modifier
		water_action.modified_value += change
		gray_water_data.refresh_ui(combat_main)

func _find_free_waters(tool_datas:Array) -> Array:
	var gray_waters:Array = tool_datas.filter(func(tool_data:ToolData) -> bool:
		return tool_data.id == "free_water"
	)
	return gray_waters
