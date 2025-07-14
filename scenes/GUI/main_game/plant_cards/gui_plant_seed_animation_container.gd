class_name GUIPlantSeedAnimationContainer
extends Control

signal draw_plant_card_completed(field_index:int, plant_data:PlantData)

const ANIMATING_PLANT_SEED_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")
const SEED_ICON_DISAPPEAR_TIME := 0.4

var _field_container:FieldContainer: get = _get_field_container
var _draw_deck_button:GUIDeckButton: get = _get_draw_deck_button
var _discard_deck_button:GUIDeckButton: get = _get_discard_deck_button
var _weak_draw_deck_button:WeakRef = weakref(null)
var _weak_discard_deck_button:WeakRef = weakref(null)
var _weak_field_container:WeakRef = weakref(null)

func setup(field_container:FieldContainer, draw_box_button:GUIDeckButton, discard_box_button:GUIDeckButton) -> void:
	_weak_field_container = weakref(field_container)
	_weak_draw_deck_button = weakref(draw_box_button)
	_weak_discard_deck_button = weakref(discard_box_button)

func animate_draw(draw_results:Array, target_field_indices:Array) -> void:
	assert(draw_results.size() == target_field_indices.size())
	var animating_cards:Array[GUIPlantIcon] = []
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for i:int in draw_results.size():
		var animating_card:GUIPlantIcon = ANIMATING_PLANT_SEED_SCENE.instantiate()
		add_child(animating_card)
		animating_card.update_with_plant_data(draw_results[i])
		animating_card.hide()
		animating_card.global_position = _draw_deck_button.global_position
		animating_cards.append(animating_card)
		var delay_index := i
		if delay_index >= 0:
			Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * delay_index).timeout.connect(func(): animating_card.play_move_sound())
		var field := _field_container.fields[target_field_indices[i]]
		var target_position := field.get_preview_icon_global_position(animating_card)
		tween.tween_property(animating_card, "visible", true, 0.01).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(animating_card, "global_position", target_position, Constants.PLANT_SEED_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		var disappear_tween := tween.tween_property(animating_card, "modulate:a", 0, SEED_ICON_DISAPPEAR_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index + Constants.PLANT_SEED_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		disappear_tween.finished.connect(func():
			draw_plant_card_completed.emit(target_field_indices[i], draw_results[i])
		)
	await tween.finished
	for card in animating_cards:
		card.queue_free()

func animate_shuffle(discard_pile_cards:Array) -> void:
	if discard_pile_cards.size() == 0:
		return
	var index := 0
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for tool_data:ToolData in discard_pile_cards:
		var animating_card:GUIPlantIcon = ANIMATING_PLANT_SEED_SCENE.instantiate()
		add_child(animating_card)
		animating_card.update_with_tool_data(tool_data)
		animating_card.global_position = _discard_deck_button.global_position
		var target_position := _draw_deck_button.global_position
		Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * index - 0.01).timeout.connect(func(): animating_card.play_move_sound())
		var tweener := tween.tween_property(animating_card, "global_position", target_position, Constants.PLANT_SEED_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * index)
		tweener.finished.connect(func():
			animating_card.queue_free()
		)
		index += 1
	await tween.finished

func animate_discard(field_indices:Array, discarding_data:Array) -> void:
	var discarding_cards:Array[GUIPlantIcon] = []
	var discard_tween:Tween = Util.create_scaled_tween(self)
	discard_tween.set_parallel(true)
	for i:int in field_indices.size():
		var field_index:int = field_indices[i]
		var field := _field_container.fields[field_index]
		var card:GUIPlantIcon = ANIMATING_PLANT_SEED_SCENE.instantiate()
		add_child(card)
		card.update_with_plant_data(discarding_data[i])
		discarding_cards.append(card)
		card.global_position = field.get_preview_icon_global_position(card)
		var target_position := _discard_deck_button.global_position
		discard_tween.tween_property(card, "global_position", target_position, Constants.PLANT_SEED_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY).set_delay(Constants.CARD_ANIMATION_DELAY * i).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await discard_tween.finished
	for discarding_card in discarding_cards:
		discarding_card.queue_free()

func _get_field_container() -> FieldContainer:
	return _weak_field_container.get_ref()

func _get_draw_deck_button() -> GUIDeckButton:
	return _weak_draw_deck_button.get_ref()

func _get_discard_deck_button() -> GUIDeckButton:
	return _weak_discard_deck_button.get_ref()
