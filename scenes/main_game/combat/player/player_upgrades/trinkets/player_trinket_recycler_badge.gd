class_name PlayerTrinketRecyclerBadge
extends PlayerTrinket

func _has_pool_updated_hook(_combat_main: CombatMain, pool: Array) -> bool:
	return _find_free_waters(pool).size() > 0

func _handle_pool_updated_hook(combat_main: CombatMain, pool: Array) -> void:
	for free_water_data: ToolData in _find_free_waters(pool):
		var old_modifier: int = free_water_data.data.get(&"recycler_badge", 0) as int
		free_water_data.data[&"recycler_badge"] = 1
		var water_action: ActionData = free_water_data.actions[0]
		assert(water_action.type == ActionData.ActionType.WATER)
		water_action.modified_value += 1 - old_modifier
		free_water_data.refresh_ui(combat_main)

func _find_free_waters(pool: Array) -> Array:
	return pool.filter(func(tool_data: ToolData) -> bool:
		return tool_data.id == "free_water"
	)
