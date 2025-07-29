class_name GUIToolCardAnimationContainer
extends Control

const ANIMATING_TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const DRAW_ANIMATION_TIME := 0.4
const DISCARD_ANIMATION_TIME := 0.4
const CARD_MIN_SCALE := 0.8
const MAX_SHUFFLE_CARDS := 5

signal _animation_queue_item_finished(finished_item:AnimationQueueItem)

var _tool_card_container:GUIToolCardContainer: get = _get_tool_card_container
var _draw_deck_button:GUIDeckButton: get = _get_draw_deck_button
var _discard_deck_button:GUIDeckButton: get = _get_discard_deck_button
var _weak_tool_card_container:WeakRef = weakref(null)
var _weak_draw_deck_button:WeakRef = weakref(null)
var _weak_discard_deck_button:WeakRef = weakref(null)

var _animation_queue:Array = []

func _ready() -> void:
	_animation_queue_item_finished.connect(_on_animation_queue_item_finished)

func setup(tool_card_container:GUIToolCardContainer, draw_box_button:GUIDeckButton, discard_box_button:GUIDeckButton) -> void:
	_weak_tool_card_container = weakref(tool_card_container)
	_weak_draw_deck_button = weakref(draw_box_button)
	_weak_discard_deck_button = weakref(discard_box_button)

func animate_draw(draw_results:Array) -> void:
	if draw_results.is_empty():
		return
	var item := _enqueue_animation(AnimationQueueItem.AnimationType.ANIMATE_DRAW, [draw_results])
	await item.finished

func animate_shuffle(number_of_cards:int) -> void:
	if number_of_cards == 0:
		return
	var index := 0
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for i in mini(number_of_cards, MAX_SHUFFLE_CARDS):
		var animating_card:GUIToolCardButton = ANIMATING_TOOL_CARD_SCENE.instantiate()
		add_child(animating_card)
		animating_card.animation_mode = true
		animating_card.size = _draw_deck_button.size
		animating_card.global_position = _discard_deck_button.global_position
		var target_position := _draw_deck_button.global_position
		Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * index - 0.01).timeout.connect(func(): animating_card.play_move_sound())
		var tweener := tween.tween_property(animating_card, "global_position", target_position, DISCARD_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * index)
		tweener.finished.connect(func():
			animating_card.queue_free()
		)
		index += 1
	await tween.finished

func animate_discard(indices:Array) -> void:
	var item := _enqueue_animation(AnimationQueueItem.AnimationType.ANIMATE_DISCARD, [indices])
	await item.finished

func animate_reposition() -> void:
	if _tool_card_container.get_card_count() == 0:
		return
	var default_positions:Array[Vector2] = _tool_card_container.calculate_default_positions(_tool_card_container.get_card_count())
	var reposition_tween:Tween = Util.create_scaled_tween(self)
	reposition_tween.set_parallel(true)
	for i:int in _tool_card_container.get_card_count():
		var card:GUIToolCardButton = _tool_card_container.get_card(i)
		var target_position:Vector2 = _tool_card_container.global_position + default_positions[i]
		card.play_move_sound()
		reposition_tween.tween_property(card, "global_position", target_position, DISCARD_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await reposition_tween.finished

func _enqueue_animation(type:AnimationQueueItem.AnimationType, args:Array) -> AnimationQueueItem:
	var id := _animation_queue.size()
	var item := AnimationQueueItem.new(id, type, args)
	_animation_queue.append(item)
	if _animation_queue.size() == 1:
		_play_next_animation()
	return item

func _play_next_animation() -> void:
	if _animation_queue.is_empty():
		return
	var next_item:AnimationQueueItem = _animation_queue.pop_front()
	match next_item.animation_type:
		AnimationQueueItem.AnimationType.ANIMATE_DRAW:
			_animate_draw(next_item)
		AnimationQueueItem.AnimationType.ANIMATE_DISCARD:
			_animate_discard(next_item)

func _animate_draw(animation_item:AnimationQueueItem) -> void:
	var draw_results:Array = animation_item.animation_args[0].duplicate()
	var total_card_count:int = _tool_card_container.get_card_count() + draw_results.size()
	var card_positions:Array[Vector2] = _tool_card_container.calculate_default_positions(total_card_count)
	var starting_index:int = _tool_card_container.get_card_count()
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	var animating_cards:Array[GUIToolCardButton] = []
	var delay_index = 0
	for i in total_card_count:
		var animating_card:GUIToolCardButton
		if i < starting_index:
			animating_card = _tool_card_container.get_card(i)
		else:
			animating_card = _tool_card_container.add_card(draw_results[i - starting_index])
			animating_card.hide()
			animating_card.animation_mode = true
			animating_card.global_position = _draw_deck_button.global_position
			animating_card.size = _draw_deck_button.size
			delay_index += 1
		animating_cards.append(animating_card)
		if delay_index >= 0:
			Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * delay_index).timeout.connect(func(): animating_card.play_move_sound())
		var card_local_position:Vector2 = card_positions[i]
		var target_global_position:Vector2 = _tool_card_container.global_position + card_local_position
		tween.tween_property(animating_card, "visible", true, 0.01).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(animating_card, "global_position", target_global_position, DRAW_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var scale_tweener := tween.tween_property(animating_card, "size", GUIToolCardButton.SIZE, DRAW_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		scale_tweener.finished.connect(_on_draw_animation_scaler_tweener_finished.bind(animating_card))
	await tween.finished
	_animation_queue_item_finished.emit(animation_item)

func _animate_discard(animation_item:AnimationQueueItem) -> void:
	var indices:Array = animation_item.animation_args[0].duplicate()
	var discarding_cards:Array[GUIToolCardButton] = []
	for i:int in _tool_card_container.get_card_count():
		var card :GUIToolCardButton = _tool_card_container.get_card(i)
		card.mouse_disabled = true
	var discard_tween:Tween = Util.create_scaled_tween(self)
	discard_tween.set_parallel(true)
	for i:int in indices:
		var card:GUIToolCardButton = _tool_card_container.get_card(i)
		discarding_cards.append(card)
		var target_size := _discard_deck_button.size
		var target_position:Vector2 = _discard_deck_button.global_position
		Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * i - 0.01).timeout.connect(func(): card.play_move_sound())
		Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * i + 0.01).timeout.connect(func(): card.animation_mode = true)
		discard_tween.tween_property(card, "global_position", target_position, DISCARD_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * i).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		discard_tween.tween_property(card, "size", target_size, DISCARD_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * i).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await discard_tween.finished
	_tool_card_container.remove_cards(discarding_cards)
	await animate_reposition()
	_animation_queue_item_finished.emit(animation_item)

func _get_tool_card_container() -> GUIToolCardContainer:
	return _weak_tool_card_container.get_ref()

func _get_draw_deck_button() -> GUIDeckButton:
	return _weak_draw_deck_button.get_ref()

func _get_discard_deck_button() -> GUIDeckButton:
	return _weak_discard_deck_button.get_ref()

func _on_animation_queue_item_finished(finished_item:AnimationQueueItem) -> void:
	finished_item.finished.emit()
	_play_next_animation()

func _on_draw_animation_scaler_tweener_finished(card:GUIToolCardButton) -> void:
	card.animation_mode = false

class AnimationQueueItem:

	@warning_ignore("unused_signal")
	signal finished()

	enum AnimationType {
		ANIMATE_DRAW,
		ANIMATE_DISCARD,
	}

	var animation_type:AnimationType
	var animation_args:Array
	var id:int

	func _init(identifier:int, type:AnimationType, args:Array) -> void:
		id = identifier
		animation_type = type
		animation_args = args
	
