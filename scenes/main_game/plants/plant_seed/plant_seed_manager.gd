class_name PlantSeedManager
extends RefCounted

var plant_datas:Array[PlantData]
var _current_index := 0

func _init(datas:Array[PlantData]) -> void:
	for plant_data in datas:
		plant_datas.append(plant_data.get_duplicate())
	_current_index = 0

func has_more_plants() -> bool:
	return _current_index < plant_datas.size()

func draw_plants(field_indices:Array, gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer) -> void:
	var count := field_indices.size()
	var draw_slice_end := mini(plant_datas.size(), _current_index + count)
	var draw_results:Array = []
	for i in range(_current_index, draw_slice_end):
		draw_results.append(i)
	var planting_fields := field_indices.slice(0, draw_results.size())
	await gui_plant_seed_animation_container.animate_draw(plant_datas, draw_results, planting_fields)
	_current_index += count

func finish_plants(field_indices:Array, harvestable_plant_datas:Array, gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer) -> void:
	var harvestable_card_indices:Array = harvestable_plant_datas.map(func(plant_data:PlantData): return plant_datas.find(plant_data))
	await gui_plant_seed_animation_container.animate_finish(field_indices, harvestable_plant_datas, harvestable_card_indices)
