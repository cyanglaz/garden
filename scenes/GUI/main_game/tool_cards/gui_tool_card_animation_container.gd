class_name GUIToolCardAnimationContainer
extends Control

const ANIMATING_TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const DRAW_ANIMATION_TIME := 0.2
const DISCARD_ANIMATION_TIME := 0.1
const CARD_MIN_SCALE := 0.8

var _tool_card_container:GUIToolCardContainer: get = _get_tool_card_container
var _draw_deck_button:GUIDeckButton: get = _get_draw_deck_button
var _discard_deck_button:GUIDeckButton: get = _get_discard_deck_button
var _weak_tool_card_container:WeakRef = weakref(null)
var _weak_draw_deck_button:WeakRef = weakref(null)
var _weak_discard_deck_button:WeakRef = weakref(null)

func setup(tool_card_container:GUIToolCardContainer, draw_box_button:GUIDeckButton, discard_box_button:GUIDeckButton) -> void:
	_weak_tool_card_container = weakref(tool_card_container)
	_weak_draw_deck_button = weakref(draw_box_button)
	_weak_discard_deck_button = weakref(discard_box_button)

func animate_draw(draw_results:Array) -> void:
	if draw_results.is_empty():
		return
	var total_card_count:int = _tool_card_container.get_card_count() + draw_results.size()
	var card_positions:Array[Vector2] = _tool_card_container.calculate_default_positions(total_card_count)
	var starting_index:int = _tool_card_container.get_card_count()
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	var animating_cards:Array[GUIToolCardButton] = []
	for i in total_card_count:
		var animating_card:GUIToolCardButton
		if i < starting_index:
			animating_card = _tool_card_container.get_card(i)
		else:
			animating_card = ANIMATING_TOOL_CARD_SCENE.instantiate()
			add_child(animating_card)
			animating_card.hide()
			animating_card.animation_mode = true
			var tool_data:ToolData = draw_results[i - starting_index]
			var original_size:Vector2 = animating_card.size
			animating_card.scale = _draw_deck_button.size/original_size * CARD_MIN_SCALE
			animating_card.global_position = _draw_deck_button.global_position + _draw_deck_button.size/2 - animating_card.size/2*animating_card.scale
			animating_card.update_with_tool_data(tool_data)
			animating_cards.append(animating_card)
		var delay_index := i - starting_index + 1
		if delay_index >= 0:
			Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * delay_index).timeout.connect(func(): animating_card.play_move_sound())
		var card_local_position:Vector2 = card_positions[i]
		var target_global_position:Vector2 = _tool_card_container.global_position + card_local_position
		tween.tween_property(animating_card, "visible", true, 0.01).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(animating_card, "global_position", target_global_position, DRAW_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		var scale_tweener := tween.tween_property(animating_card, "scale", Vector2.ONE, DRAW_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		scale_tweener.finished.connect(func():
			animating_card.animation_mode = false
		)
	await tween.finished
	for animating_card in animating_cards:
		animating_card.queue_free()

func animate_shuffle(discard_pile_cards:Array) -> void:
	if discard_pile_cards.size() == 0:
		return
	var index := 0
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for tool_data:ToolData in discard_pile_cards:
		var animating_card:GUIToolCardButton = ANIMATING_TOOL_CARD_SCENE.instantiate()
		add_child(animating_card)
		animating_card.animation_mode = true
		var original_size:Vector2 = animating_card.size
		animating_card.scale = _discard_deck_button.size/original_size * CARD_MIN_SCALE
		animating_card.update_with_tool_data(tool_data)
		animating_card.global_position = _discard_deck_button.global_position + _discard_deck_button.size/2 - animating_card.size/2*animating_card.scale
		var target_position := _draw_deck_button.global_position + _draw_deck_button.size/2 - animating_card.size/2*animating_card.scale
		Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * index - 0.01).timeout.connect(func(): animating_card.play_move_sound())
		var tweener := tween.tween_property(animating_card, "global_position", target_position, DISCARD_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * index)
		tweener.finished.connect(func():
			animating_card.queue_free()
		)
		index += 1
	await tween.finished

func animate_discard(indices:Array) -> void:
	var discarding_cards:Array[GUIToolCardButton] = []
	var discard_tween:Tween = Util.create_scaled_tween(self)
	discard_tween.set_parallel(true)
	for i:int in indices:
		var card:GUIToolCardButton = _tool_card_container.get_card(i)
		card.mouse_disabled = true
		discarding_cards.append(card)
		var original_size:Vector2 = card.size
		var target_scale := _discard_deck_button.size/original_size * CARD_MIN_SCALE
		var target_position:Vector2 = _discard_deck_button.global_position + _discard_deck_button.size/2 - card.size/2*target_scale
		Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * i - 0.01).timeout.connect(func(): card.play_move_sound())
		Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY + 0.01).timeout.connect(func(): card.animation_mode = true)
		discard_tween.tween_property(card, "global_position", target_position, DISCARD_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * i).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		discard_tween.tween_property(card, "scale", Vector2.ONE * target_scale, DISCARD_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * i).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await discard_tween.finished
	for discarding_card in discarding_cards:
		_tool_card_container.remove_card(discarding_card)
		discarding_card.hide()
		discarding_card.queue_free()
	if _tool_card_container.get_card_count() > 0:
		var default_positions:Array[Vector2] = _tool_card_container.calculate_default_positions(_tool_card_container.get_card_count())
		var reposition_tween:Tween = Util.create_scaled_tween(self)
		reposition_tween.set_parallel(true)
		for i:int in _tool_card_container.get_card_count():
			var card:GUIToolCardButton = _tool_card_container.get_card(i)
			var target_position:Vector2 = _tool_card_container.global_position + default_positions[i]
			Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * i - 0.01).timeout.connect(func(): card.play_move_sound())
			reposition_tween.tween_property(card, "global_position", target_position, DISCARD_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * i).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await reposition_tween.finished

func _get_tool_card_container() -> GUIToolCardContainer:
	return _weak_tool_card_container.get_ref()

func _get_draw_deck_button() -> GUIDeckButton:
	return _weak_draw_deck_button.get_ref()

func _get_discard_deck_button() -> GUIDeckButton:
	return _weak_discard_deck_button.get_ref()
