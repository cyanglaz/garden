class_name PlantSeedManager
extends RefCounted

var _plant_datas:Array[PlantData]
var _current_index := 0

func _init(plant_datas:Array[PlantData]) -> void:
	_plant_datas = plant_datas
	_current_index = 0

func draw_cards(count:int, gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer, field_indices:Array, field_container:FieldContainer) -> void:
	var draw_slice_end := mini(_plant_datas.size(), _current_index + count)
	var draw_results:Array = _plant_datas.slice(_current_index, draw_slice_end)
	var planting_fields := field_indices.slice(0, draw_results.size())
	await gui_plant_seed_animation_container.animate_draw(draw_results, planting_fields)
	_current_index += count
