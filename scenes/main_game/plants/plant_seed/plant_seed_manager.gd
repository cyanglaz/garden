class_name PlantSeedManager
extends RefCounted

var _plant_datas:Array[PlantData]
var _current_index := 0

func _init(plant_datas:Array[PlantData]) -> void:
	_plant_datas = plant_datas
	_current_index = 0

func has_more_plants() -> bool:
	return _current_index < _plant_datas.size()

func draw_plants(count:int, gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer, field_indices:Array) -> void:
	var draw_slice_end := mini(_plant_datas.size(), _current_index + count)
	var draw_results:Array = []
	for i in range(_current_index, draw_slice_end):
		draw_results.append(i)
	var planting_fields := field_indices.slice(0, draw_results.size())
	await gui_plant_seed_animation_container.animate_draw(_plant_datas, draw_results, planting_fields)
	_current_index += count
