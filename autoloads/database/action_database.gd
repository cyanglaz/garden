class_name ActionDatabase
extends Database

const DIR = "res://data/actions"

func roll_actions(number_of_actions:int) -> Array[ActionData]:
	var all_actions := get_all_datas()
	var actions:Array[ActionData] = Util.unweighted_roll(all_actions, number_of_actions)
	return actions

func _get_data_dir() -> String:
	return DIR
