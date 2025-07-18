class_name ToolDatabase
extends Database

const DIR = "res://data/tools"

func roll_tools(number_of_tools:int) -> Array[ToolData]:
	var available_tools:Array = _datas.values().duplicate()
	var result:Array[ToolData] = []
	for i in number_of_tools:
		var tool_data:ToolData = available_tools.pick_random()
		result.append(tool_data.get_duplicate())
		available_tools.erase(tool_data)
	return result

func _get_data_dir() -> String:
	return DIR
