class_name GUIToolCardAnimationContainer
extends Control

const ANIMATING_TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const DRAW_ANIMATION_TIME := 0.3
const DISCARD_ANIMATION_TIME := 0.3
const REPOSITION_ANIMATION_TIME := 0.15
const CARD_MIN_SCALE := 0.8
const MAX_SHUFFLE_CARDS := 5
const ADD_CARD_TO_PILE_ANIMATION_TIME := 0.5
const ADD_CARD_TO_PILE_PAUSE_TIME := 0.15
const USE_CARD_OFFSET := 40
const USE_CARD_PAUSE_TIME := 0.2
const USE_CARD_DISCARD_DELAY := 0.2

signal _animation_queue_item_finished(finished_item:AnimationQueueItem)

var _tool_card_container:GUIToolCardContainer: get = _get_tool_card_container
var _draw_deck_button:GUIDeckButton: get = _get_draw_deck_button
var _discard_deck_button:GUIDeckButton: get = _get_discard_deck_button
var _weak_tool_card_container:WeakRef = weakref(null)
var _weak_draw_deck_button:WeakRef = weakref(null)
var _weak_discard_deck_button:WeakRef = weakref(null)

var _animation_queue:Array = []
var _in_use_card:GUIToolCardButton
var _reposition_tween:Tween

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
		animating_card.mouse_disabled = true
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

func animate_use_card(tool_data:ToolData) -> void:
	var item := _enqueue_animation(AnimationQueueItem.AnimationType.ANIMATE_USE_CARD, [tool_data])
	await item.finished

func animate_discard(tool_datas:Array) -> void:
	var in_use_card:ToolData
	var in_hand_cards:Array = []
	for tool_data in tool_datas:
		if _in_use_card && tool_data == _in_use_card._tool_data:
			in_use_card = tool_data
		else:
			in_hand_cards.append(tool_data)
	if in_use_card:
		_animate_discard_in_use_card()
	if in_hand_cards.size() > 0:
		var item := _enqueue_animation(AnimationQueueItem.AnimationType.ANIMATE_DISCARD, [in_hand_cards])
		await item.finished

func animate_add_card_to_draw_pile(tool_data:ToolData, from_global_position:Vector2, pause:bool) -> void:
	var item := _enqueue_animation(AnimationQueueItem.AnimationType.ANIMATE_ADD_CARD_TO_DRAW_PILE, [tool_data, from_global_position, pause])
	await item.finished

func animate_exhaust(tool_datas:Array) -> void:
	var in_use_card:ToolData
	var in_hand_cards:Array = []
	for tool_data in tool_datas:
		if tool_data == _in_use_card._tool_data:
			in_use_card = tool_data
		else:
			in_hand_cards.append(tool_data)
	if in_use_card:
		_animate_exhaust_in_use_card()
	if in_hand_cards.size() > 0:
		var item := _enqueue_animation(AnimationQueueItem.AnimationType.ANIMATE_EXHAUST, [in_hand_cards])
		await item.finished

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
	var next_item:AnimationQueueItem = _animation_queue.front()
	match next_item.animation_type:
		AnimationQueueItem.AnimationType.ANIMATE_DRAW:
			_animate_draw(next_item)
		AnimationQueueItem.AnimationType.ANIMATE_DISCARD:
			_animate_discard(next_item)
		AnimationQueueItem.AnimationType.ANIMATE_ADD_CARD_TO_DRAW_PILE:
			_animate_add_card_to_draw_pile(next_item)
		AnimationQueueItem.AnimationType.ANIMATE_USE_CARD:
			_animate_use_card(next_item)

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
		animating_card.mouse_disabled = true
		animating_cards.append(animating_card)
		if delay_index >= 0:
			Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * delay_index).timeout.connect(func(): animating_card.play_move_sound())
		var card_local_position:Vector2 = card_positions[i]
		var target_global_position:Vector2 = _tool_card_container.global_position + card_local_position
		tween.tween_property(animating_card, "visible", true, 0.01).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(animating_card, "global_position", target_global_position, DRAW_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(animating_card, "size", GUIToolCardButton.SIZE, DRAW_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * delay_index).timeout.connect(func(): 
			animating_card.mouse_disabled = false
			animating_card.animation_mode = false
		)
	await tween.finished
	_animation_queue_item_finished.emit(animation_item)

func _animate_discard(animation_item:AnimationQueueItem) -> void:
	var tool_datas:Array = animation_item.animation_args[0].duplicate()
	var discarding_cards:Array[GUIToolCardButton] = []
	var discard_tween:Tween = Util.create_scaled_tween(self)
	discard_tween.set_parallel(true)
	var index := 0
	for card:GUIToolCardButton in _tool_card_container.get_all_cards():
		if tool_datas.has(card._tool_data):
			discarding_cards.append(card)
			_animate_discard_a_card(card, discard_tween, Constants.CARD_ANIMATION_DELAY * index)
			index += 1
	await discard_tween.finished
	_tool_card_container.remove_cards(discarding_cards)
	await _animate_reposition()
	_animation_queue_item_finished.emit(animation_item)

func _animate_exhaust(animation_item:AnimationQueueItem) -> void:
	var tool_datas:Array = animation_item.animation_args[0].duplicate()
	var exhausting_cards:Array[GUIToolCardButton] = []
	for card:GUIToolCardButton in _tool_card_container.get_all_cards():
		if tool_datas.has(card._tool_data):
			exhausting_cards.append(card)
			await card.play_exhaust_animation()
	_tool_card_container.remove_cards(exhausting_cards)
	await _animate_reposition()
	_animation_queue_item_finished.emit(animation_item)

func _animate_add_card_to_draw_pile(animation_item:AnimationQueueItem) -> void:
	var tool_data:ToolData = animation_item.animation_args[0]
	var from_global_position:Vector2 = animation_item.animation_args[1]
	var pause:bool = animation_item.animation_args[2]
	var animating_card:GUIToolCardButton = ANIMATING_TOOL_CARD_SCENE.instantiate()
	add_child(animating_card)
	animating_card.update_with_tool_data(tool_data)
	animating_card.global_position = from_global_position - GUIToolCardButton.SIZE / 2
	animating_card.mouse_disabled = true
	if pause:
		await Util.create_scaled_timer(ADD_CARD_TO_PILE_PAUSE_TIME).timeout
	animating_card.play_move_sound()
	Util.create_scaled_timer(ADD_CARD_TO_PILE_ANIMATION_TIME * 0.25).timeout.connect(func(): animating_card.animation_mode = true)
	var tween := Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.tween_property(animating_card, "global_position", _draw_deck_button.global_position, ADD_CARD_TO_PILE_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(animating_card, "size", _draw_deck_button.size, ADD_CARD_TO_PILE_ANIMATION_TIME * 0.75).set_delay(ADD_CARD_TO_PILE_ANIMATION_TIME * 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	animating_card.queue_free()
	_animation_queue_item_finished.emit(animation_item)

func _animate_use_card(animation_item:AnimationQueueItem) -> void:
	var tool_data:ToolData = animation_item.animation_args[0]
	var card:GUIToolCardButton = _tool_card_container.find_card(tool_data)
	assert(_in_use_card == null)
	_in_use_card = ANIMATING_TOOL_CARD_SCENE.instantiate()
	add_child(_in_use_card)
	_in_use_card.card_state = GUIToolCardButton.CardState.HIGHLIGHTED
	_in_use_card.update_with_tool_data(card._tool_data)
	_in_use_card.global_position = card.global_position
	_in_use_card.mouse_disabled = true
	_in_use_card.play_use_sound()
	_tool_card_container.remove_cards([card])
	#_animate_reposition()
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.tween_property(_in_use_card, "global_position", _in_use_card.global_position + Vector2.UP * USE_CARD_OFFSET, REPOSITION_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	await Util.create_scaled_timer(USE_CARD_PAUSE_TIME).timeout
	_animation_queue_item_finished.emit(animation_item)

func _animate_discard_in_use_card() -> void:
	assert(_in_use_card != null)
	var in_use_card := _in_use_card
	_in_use_card = null
	var discard_tween := Util.create_scaled_tween(self)
	discard_tween.set_parallel(true)
	_animate_discard_a_card(in_use_card, discard_tween, 0)
	await discard_tween.finished
	_animate_reposition()
	in_use_card.queue_free()

func _animate_exhaust_in_use_card() -> void:
	assert(_in_use_card != null)
	var in_use_card := _in_use_card
	_in_use_card = null
	await in_use_card.play_exhaust_animation()
	# exhaust the card
	_animate_reposition()
	in_use_card.queue_free()

func _animate_discard_a_card(card:GUIToolCardButton, tween:Tween, delay:float) -> void:
	var animating_card:GUIToolCardButton = ANIMATING_TOOL_CARD_SCENE.instantiate()
	add_child(animating_card)
	animating_card.update_with_tool_data(card._tool_data)
	animating_card.global_position = card.global_position
	animating_card.hide()
	animating_card.animation_mode = true
	animating_card.mouse_disabled = true
	Util.create_scaled_timer(delay - 0.01).timeout.connect(func(): animating_card.play_move_sound())
	Util.create_scaled_timer(delay + 0.01).timeout.connect(func(): animating_card.show())
	Util.create_scaled_timer(delay + 0.01).timeout.connect(func(): card.hide())
	var target_size := _discard_deck_button.size
	var target_position:Vector2 = _discard_deck_button.global_position
	tween.set_parallel(true)
	tween.tween_property(animating_card, "global_position", target_position, DISCARD_ANIMATION_TIME).set_delay(delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var scale_tweener := tween.tween_property(animating_card, "size", target_size, DISCARD_ANIMATION_TIME).set_delay(delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	scale_tweener.finished.connect(func():
		animating_card.queue_free()
	)

func _animate_reposition() -> void:
	if _tool_card_container.get_card_count() == 0:
		return
	if _reposition_tween && _reposition_tween.is_running():
		_reposition_tween.kill()
	var default_positions:Array[Vector2] = _tool_card_container.calculate_default_positions(_tool_card_container.get_card_count())
	_reposition_tween = Util.create_scaled_tween(self)
	_reposition_tween.set_parallel(true)
	for i:int in _tool_card_container.get_card_count():
		var card:GUIToolCardButton = _tool_card_container.get_card(i)
		var target_position:Vector2 = _tool_card_container.global_position + default_positions[i]
		_reposition_tween.tween_property(card, "global_position", target_position, REPOSITION_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await _reposition_tween.finished

func _get_tool_card_container() -> GUIToolCardContainer:
	return _weak_tool_card_container.get_ref()

func _get_draw_deck_button() -> GUIDeckButton:
	return _weak_draw_deck_button.get_ref()

func _get_discard_deck_button() -> GUIDeckButton:
	return _weak_discard_deck_button.get_ref()

func _on_animation_queue_item_finished(finished_item:AnimationQueueItem) -> void:
	finished_item.finished.emit()
	_animation_queue.pop_front()
	_play_next_animation()

class AnimationQueueItem:

	@warning_ignore("unused_signal")
	signal finished()

	enum AnimationType {
		ANIMATE_DRAW,
		ANIMATE_DISCARD,
		ANIMATE_ADD_CARD_TO_DRAW_PILE,
		ANIMATE_USE_CARD,
		ANIMATE_EXHAUST,
	}

	var animation_type:AnimationType
	var animation_args:Array
	var id:int

	func _init(identifier:int, type:AnimationType, args:Array) -> void:
		id = identifier
		animation_type = type
		animation_args = args
	
