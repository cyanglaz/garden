class_name WeatherDatabase
extends Database

const DIR = "res://data/weathers"

func get_weathers_by_chapter(chapter:int) -> Array[WeatherData]:
	var chapter_weathers := _get_all_resources(_datas, str("chapter", chapter)).values()
	var all_chapter_weathers := _get_all_resources(_datas, "all_chapters").values()
	var result:Array[WeatherData] = []
	for weather_data in chapter_weathers + all_chapter_weathers:
		result.append(weather_data.get_duplicate())
	return result

func _get_data_dir() -> String:
	return DIR
