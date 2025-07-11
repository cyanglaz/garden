class_name PlantSeedManager
extends RefCounted

signal plant_application_started()
signal plant_application_completed(index:int)

var plant_deck:Deck

func _init(initial_plants:Array) -> void:
	plant_deck = Deck.new(initial_plants)

func draw_cards(count:int, gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer, field_indices:Array, field_container:FieldContainer) -> void:
	var _display_index = plant_deck.hand.size() - 1
	var draw_results:Array = plant_deck.draw(count)
	var planting_fields := field_indices.slice(0, draw_results.size())
	await gui_plant_seed_animation_container.animate_draw(draw_results, planting_fields)
	plant_seeds(draw_results, planting_fields, field_container)
	if draw_results.size() < count:
		planting_fields = field_indices.slice(draw_results.size(), count - draw_results.size())
		# If no sufficient cards in draw pool, shuffle discard pile and draw again.
		await shuffle(gui_plant_seed_animation_container)
		var second_draw_result:Array = plant_deck.draw(count - draw_results.size())
		await gui_plant_seed_animation_container.animate_draw(second_draw_result, planting_fields)
		plant_seeds(second_draw_result, planting_fields, field_container)

func shuffle(gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer) -> void:
	var discard_pile_balls := plant_deck.discard_pool.duplicate()
	await gui_plant_seed_animation_container.animate_shuffle(discard_pile_balls)
	plant_deck.shuffle_draw_pool()

func discard_cards(field_indices:Array, gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer) -> void:
	var discarding_data := field_indices.map(func(i:int): return plant_deck.hand[i])
	await gui_plant_seed_animation_container.animate_discard(field_indices,discarding_data)
	plant_deck.discard(field_indices)

func plant_seeds(plant_datas:Array, field_indices:Array, field_container:FieldContainer) -> void:
	for i in plant_datas.size():
		var field_index:int = field_indices[i]
		var field:Field = field_container.fields[field_index]
		field.plant_seed(plant_datas[i])

func get_plant(index:int) -> ToolData:
	return plant_deck.get_item(index)
