class_name PlayerTrinketRecyclerBadge
extends PlayerTrinket

func _has_start_turn_hook(combat_main: CombatMain) -> bool:
	if combat_main.day_manager.day == 0:
		return true
	return false

func _handle_start_turn_hook(combat_main: CombatMain) -> void:
	request_player_upgrade_hook_animation.emit(data.id)
	for free_water_data: ToolData in _find_free_waters(combat_main.tool_manager.tool_deck.pool):
		_update_free_water(free_water_data, combat_main)

func _has_pool_updated_hook(_combat_main: CombatMain, pool: Array) -> bool:
	return _find_free_waters(pool).size() > 0

func _handle_pool_updated_hook(combat_main: CombatMain, pool: Array) -> void:
	for free_water_data: ToolData in _find_free_waters(pool):
		_update_free_water(free_water_data, combat_main)

func _find_free_waters(pool: Array) -> Array:
	return pool.filter(func(tool_data: ToolData) -> bool:
		return tool_data.id == "free_water"
	)

func _update_free_water(free_water_data: ToolData, combat_main: CombatMain) -> void:
	var old_modifier: int = free_water_data.data.get(&"recycler_badge", 0) as int
	free_water_data.data[&"recycler_badge"] = 1
	var water_action: ActionData = free_water_data.actions[0]
	assert(water_action.type == ActionData.ActionType.WATER)
	water_action.modified_value += 1 - old_modifier
	free_water_data.refresh_ui(combat_main)