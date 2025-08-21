class_name PlantSeedManager
extends RefCounted

var plant_deck:Deck

func _init(initial_plants:Array) -> void:
	plant_deck = Deck.new(initial_plants)

func refresh_deck() -> void:
	plant_deck.refresh()

func draw_cards(count:int, gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer, field_indices:Array, field_container:FieldContainer) -> void:
	gui_plant_seed_animation_container.draw_plant_card_completed.connect(_on_draw_plant_card_completed.bind(field_container))
	var _display_index = plant_deck.hand.size() - 1
	var draw_results:Array = plant_deck.draw(count, field_indices)
	var planting_fields := field_indices.slice(0, draw_results.size())
	await gui_plant_seed_animation_container.animate_draw(draw_results, planting_fields)
	if draw_results.size() < count:
		planting_fields = field_indices.slice(draw_results.size(), count - draw_results.size() + 1)
		# If no sufficient cards in draw pool, shuffle discard pile and draw again.
		await shuffle(gui_plant_seed_animation_container)
		var second_draw_result:Array = plant_deck.draw(count - draw_results.size(), planting_fields)
		await gui_plant_seed_animation_container.animate_draw(second_draw_result, planting_fields)
	gui_plant_seed_animation_container.draw_plant_card_completed.disconnect(_on_draw_plant_card_completed.bind(field_container))

func shuffle(gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer) -> void:
	var discard_pile_seeds := plant_deck.discard_pool.duplicate()
	await gui_plant_seed_animation_container.animate_shuffle(discard_pile_seeds)
	plant_deck.shuffle_draw_pool()

func discard_cards(field_indices:Array, gui_plant_seed_animation_container:GUIPlantSeedAnimationContainer, field_container:FieldContainer) -> void:
	var discarding_data := field_indices.map(func(i:int): return plant_deck.hand[i])
	await gui_plant_seed_animation_container.animate_discard(field_indices,discarding_data)
	remove_plants(field_indices, field_container)
	var plant_datas := field_indices.map(func(i:int): return plant_deck.hand[i])
	plant_deck.discard(plant_datas)

func remove_plants(field_indices:Array, field_container:FieldContainer) -> void:
	for field_index:int in field_indices:
		var field:Field = field_container.fields[field_index]
		field.remove_plant()

func get_plant(index:int) -> ToolData:
	return plant_deck.get_item(index)

func add_plant(plant_data:PlantData) -> void:
	plant_deck.add_item(plant_data)

func _on_draw_plant_card_completed(field_index:int, plant_data:PlantData, field_container:FieldContainer) -> void:
	var field:Field = field_container.fields[field_index]
	field.plant_seed(plant_data)
