class_name ToolDatabase
extends Database

const DIR = "res://data/tools"

func roll_tools(number_of_tools:int, rarity:int) -> Array[ToolData]:
	var available_tools:Array = _get_all_resources(_datas, "purchasable").values().duplicate()
	if rarity >= 0:
		available_tools = available_tools.filter(func(tool_data:ToolData) -> bool: return tool_data.rarity == rarity)
	var result:Array[ToolData] = []
	for i in number_of_tools:
		var tool_data:ToolData = available_tools.pick_random()
		result.append(tool_data.get_duplicate())
		available_tools.erase(tool_data)
	return result

func _get_data_dir() -> String:
	return DIR

func _evaluate_data(tool_data:Resource) -> void:
	assert(tool_data is ToolData)
	for action:ActionData in (tool_data as ToolData).actions:
		var action_type := action.type
		assert(action_type in ActionData.ActionType.values())
