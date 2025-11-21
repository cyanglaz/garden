class_name GUIPlantSeedAnimationContainer
extends Control

signal draw_plant_card_completed(plant_data:PlantData)

const ANIMATING_PLANT_SEED_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")
const SEED_ICON_DISAPPEAR_TIME := 0.4

var _plant_field_container:PlantFieldContainer: get = _get_plant_field_container
var _plant_deck_box:GUIPlantDeckBox: get = _get_plant_deck_box
var _weak_plant_deck_box:WeakRef = weakref(null)
var _weak_plant_field_container:WeakRef = weakref(null)

func setup(plant_field_container:PlantFieldContainer, plant_deck_box:GUIPlantDeckBox) -> void:
	_weak_plant_field_container = weakref(plant_field_container)
	_weak_plant_deck_box = weakref(plant_deck_box)

func animate_draw(plant_datas:Array[PlantData], draw_results:Array, target_field_indices:Array) -> void:
	assert(draw_results.size() == target_field_indices.size())
	if draw_results.size() == 0:
		return
	_plant_deck_box.remove_texture(draw_results)
	var animating_cards:Array[GUIPlantIcon] = []
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for i:int in draw_results.size():
		var index:int = draw_results[i]
		var plant_data = plant_datas[index]
		var animating_card:GUIPlantIcon = ANIMATING_PLANT_SEED_SCENE.instantiate()
		add_child(animating_card)
		animating_card.update_with_plant_data(plant_data)
		animating_card.global_position = _plant_deck_box.get_icon_position(index)
		animating_cards.append(animating_card)
		var delay_index := i
		if delay_index >= 0:
			Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * delay_index).timeout.connect(func(): animating_card.play_move_sound())
		var target_position := _plant_field_container.get_preview_icon_global_position(animating_card, target_field_indices[i])
		tween.tween_property(animating_card, "global_position", target_position, Constants.PLANT_SEED_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		var disappear_tween := tween.tween_property(animating_card, "modulate:a", 0, SEED_ICON_DISAPPEAR_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index + Constants.PLANT_SEED_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		disappear_tween.finished.connect(func():
			draw_plant_card_completed.emit(plant_data)
		)
	await tween.finished
	for card in animating_cards:
		card.queue_free()

func _get_plant_field_container() -> PlantFieldContainer:
	return _weak_plant_field_container.get_ref()

func _get_plant_deck_box() -> GUIPlantDeckBox:
	return _weak_plant_deck_box.get_ref()
