class_name PlantDatabase
extends Database

const DIR = "res://data/plants"

func get_plants_by_chapter(chapter:int) -> Array[PlantData]:
	var chapter_plants := _get_all_resources(_datas, str("chapter", chapter)).values()
	var all_chapter_plants := _get_all_resources(_datas, "all_chapters").values()
	var result:Array[PlantData] = []
	for plant_data in chapter_plants + all_chapter_plants:
		result.append(plant_data.get_duplicate())
	return result

func _get_data_dir() -> String:
	return DIR
