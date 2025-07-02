class_name WeatherDatabase
extends Database

const DIR = "res://data/weathers"

func roll_weathers(number_of_weathers:int, _week:int) -> Array[WeatherData]:
	var available_weathers:Array = _datas.values()
	var result:Array[WeatherData] = []
	for i in number_of_weathers:
		result.append(available_weathers.pick_random().get_duplicate())
	return result

func _get_data_dir() -> String:
	return DIR
