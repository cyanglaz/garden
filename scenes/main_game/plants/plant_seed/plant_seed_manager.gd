class_name PlantSeedManager
extends RefCounted

var plant_datas:Array[PlantData]
var _current_index := 0

func _init(datas:Array[PlantData]) -> void:
	for plant_data in datas:
		plant_datas.append(plant_data.get_duplicate())
	_current_index = 0

func draw_plants(number_of_plants:int, gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer) -> void:
	var draw_slice_end := mini(plant_datas.size(), _current_index + number_of_plants)
	var draw_results:Array = []
	for i in range(_current_index, draw_slice_end):
		draw_results.append(i)
	var planting_field_indices := []
	for i in number_of_plants:
		planting_field_indices.append(_current_index)
		_current_index += 1
	await gui_plant_seed_animation_container.animate_draw(plant_datas, draw_results, planting_field_indices)

func is_all_plants_drawn() -> bool:
	return _current_index >= plant_datas.size()
