class_name PlantManager
extends RefCounted

signal plant_application_started()
signal plant_application_completed(index:int)

var plant_deck:Deck

func _init(initial_plants:Array) -> void:
	plant_deck = Deck.new(initial_plants)

func draw_cards(count:int, gui_plant_card_container:GUIToolCardContainer) -> void:
	var _display_index = plant_deck.hand.size() - 1
	var draw_results:Array = plant_deck.draw(count)
	await gui_plant_card_container.animate_draw(draw_results)
	gui_plant_card_container.setup_with_plant_datas(plant_deck.hand)
	if draw_results.size() < count:
		# If no sufficient cards in draw pool, shuffle discard pile and draw again.
		await shuffle(gui_plant_card_container)
		var second_draw_result:Array = plant_deck.draw(count - draw_results.size())
		await gui_plant_card_container.animate_draw(second_draw_result)
		gui_plant_card_container.setup_with_plant_datas(plant_deck.hand)

func shuffle(gui_plant_card_container:GUIToolCardContainer) -> void:
	var discard_pile_balls := plant_deck.discard_pool.duplicate()
	await gui_plant_card_container.animate_shuffle(discard_pile_balls)
	plant_deck.shuffle_draw_pool()

func discard_cards(indices:Array, gui_plant_card_container:GUIToolCardContainer) -> void:
	await gui_plant_card_container.animate_discard(indices)
	plant_deck.discard(indices)
	gui_plant_card_container.setup_with_plant_datas(plant_deck.hand)

func get_plant(index:int) -> ToolData:
	return plant_deck.get_item(index)
