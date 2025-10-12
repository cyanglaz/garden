class_name GUIToolCardContainer
extends Control

signal tool_selected(tool_data:ToolData)
signal card_use_button_pressed(tool_data:ToolData)
signal _secondary_cards_selected()

var TOOL_CARD_SCENE := load("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")

const DEFAULT_CARD_SPACE := 1.0
const MAX_TOTAL_WIDTH := 200
const REPOSITION_DURATION:float = 0.08
const TOOL_SELECTED_OFFSET := -6.0
const CARD_SELECTION_READY_TIME := 0.2

@onready var _container: Control = %Container
@onready var _gui_tool_card_animation_container: GUIToolCardAnimationContainer = %GUIToolCardAnimationContainer
@onready var _use_card_anchor: Control = %UseCardAnchor
@onready var _card_selection_container: GUICardSelectionContainer = %CardSelectionContainer

var _card_size:float
var selected_index:int = -1
var card_use_limit_reached:bool = false: set = _set_card_use_limit_reached
var card_selection_mode := false: set = _set_card_selection_mode
var _selected_secondary_cards:Array[GUIToolCardButton] = []

func _ready() -> void:
	_card_size = GUIToolCardButton.SIZE.x

func setup(draw_box_button:GUIDeckButton, discard_box_button:GUIDeckButton) -> void:
	_gui_tool_card_animation_container.setup(self, draw_box_button, discard_box_button)

func toggle_all_tool_cards(on:bool) -> void:
	for i in get_card_count():
		var card:GUIToolCardButton = _container.get_child(i)
		card.mouse_disabled = !on

func refresh_tool_cards() -> void:
	for i in get_card_count():
		var card:GUIToolCardButton = _container.get_child(i)
		card.update_with_tool_data(card.tool_data)

func clear() -> void:
	if _container.get_children().size() == 0:
		return
	for child:GUIToolCardButton in _container.get_children():
		child.queue_free()
	Singletons.main_game.hide_warning(WarningManager.WarningType.INSUFFICIENT_ENERGY)
	_card_selection_container.end_selection()
	_selected_secondary_cards.clear()

func clear_selection() -> void:
	card_selection_mode = false
	selected_index = -1
	_card_selection_container.end_selection()
	_selected_secondary_cards.clear()
	var positions:Array[Vector2] = calculate_default_positions(_container.get_children().size())
	if positions.size() > 0:
		var tween:Tween = Util.create_scaled_tween(self)
		tween.set_parallel(true)
		for i in _container.get_children().size():
			var gui_card = _container.get_child(i)
			gui_card.card_state = GUIToolCardButton.CardState.NORMAL
			tween.tween_property(gui_card, "position", positions[i], REPOSITION_DURATION)
		await tween.finished
		for i in _container.get_children().size():
			var gui_card = _container.get_child(i)
			gui_card.z_index = 0
	Singletons.main_game.hide_warning(WarningManager.WarningType.INSUFFICIENT_ENERGY)
	Singletons.main_game.hide_warning(WarningManager.WarningType.DIALOGUE_CANNOT_USE_CARD)
	Singletons.main_game.hide_warning(WarningManager.WarningType.CARD_USE_LIMIT_REACHED)

func add_card(tool_data:ToolData) -> GUIToolCardButton:
	var gui_card:GUIToolCardButton = TOOL_CARD_SCENE.instantiate()
	_container.add_child(gui_card)
	gui_card.update_with_tool_data(tool_data)
	gui_card.activated = true
	gui_card.use_card_button_pressed.connect(_on_tool_card_use_card_button_pressed.bind(tool_data))
	if selected_index >= 0:
		gui_card.card_state = GUIToolCardButton.CardState.UNSELECTED
	else:
		gui_card.card_state = GUIToolCardButton.CardState.NORMAL
	_rebind_signals()
	gui_card.disabled = card_use_limit_reached
	return gui_card

func remove_cards(gui_cards:Array[GUIToolCardButton]) -> void:
	for gui_card in gui_cards:
		_container.remove_child(gui_card)
		gui_card.queue_free()
	_rebind_signals()

func get_all_cards() -> Array:
	return _container.get_children()

func find_card(tool_data:ToolData) -> GUIToolCardButton:
	for card:GUIToolCardButton in _container.get_children():
		if card.tool_data == tool_data:
			return card
	return null

func select_secondary_cards(number_of_cards:int) -> Array:
	assert(selected_index >= 0)
	card_selection_mode = true
	return await _card_selection_container.start_selection(number_of_cards)

func _rebind_signals() -> void:
	for i in _container.get_children().size():
		var gui_card:GUIToolCardButton = _container.get_child(i)
		if gui_card.pressed.is_connected(_on_tool_card_pressed):
			gui_card.pressed.disconnect(_on_tool_card_pressed)
		if gui_card.mouse_entered.is_connected(_on_tool_card_mouse_entered):
			gui_card.mouse_entered.disconnect(_on_tool_card_mouse_entered)
		if gui_card.mouse_exited.is_connected(_on_tool_card_mouse_exited):
			gui_card.mouse_exited.disconnect(_on_tool_card_mouse_exited)
		gui_card.pressed.connect(_on_tool_card_pressed.bind(i))
		gui_card.mouse_entered.connect(_on_tool_card_mouse_entered.bind(i))
		gui_card.mouse_exited.connect(_on_tool_card_mouse_exited.bind(i))
		gui_card.hand_index = i

#region animation

func animate_draw(draw_results:Array) -> void:
	await _gui_tool_card_animation_container.animate_draw(draw_results)
	
func animate_discard(discarding_tool_datas:Array) -> void:
	await _gui_tool_card_animation_container.animate_discard(discarding_tool_datas)

func animate_use_card(tool_data:ToolData) -> void:
	await _gui_tool_card_animation_container.animate_use_card(tool_data)

func animate_shuffle(number_of_cards:int) -> void:
	await _gui_tool_card_animation_container.animate_shuffle(number_of_cards)

func animate_add_cards_to_draw_pile(tool_datas:Array[ToolData], from_global_position:Vector2, pause:bool) -> void:
	await _gui_tool_card_animation_container.animate_add_cards_to_draw_pile(tool_datas, from_global_position, pause)

func animate_add_cards_to_discard_pile(tool_datas:Array[ToolData], from_global_position:Vector2, pause:bool) -> void:
	await _gui_tool_card_animation_container.animate_add_cards_to_discard_pile(tool_datas, from_global_position, pause)

func animate_add_cards_to_hand(hand:Array, tool_datas:Array, from_global_position:Vector2, pause:bool) -> void:
	await _gui_tool_card_animation_container.animate_add_cards_to_hand(hand, tool_datas, from_global_position, pause)

func animate_exhaust(tool_datas:Array) -> void:
	await _gui_tool_card_animation_container.animate_exhaust(tool_datas)

#endregion

func get_card(index:int) -> GUIToolCardButton:
	return _container.get_child(index)

func get_card_count() -> int:
	return _container.get_children().size()

func get_card_position(index:int) -> Vector2:
	var gui_card:GUIToolCardButton = _container.get_child(index)
	return gui_card.global_position

func get_center_position() -> Vector2:
	return _container.global_position + _container.size/2

func remove_card(card:GUIToolCardButton) -> void:
	_container.remove_child(card)

func calculate_default_positions(number_of_cards:int) -> Array[Vector2]:
	var card_space := DEFAULT_CARD_SPACE
	var total_width := number_of_cards * _card_size + card_space * (number_of_cards - 1)
	# Reduce spacing if total width exceeds max width
	if total_width > MAX_TOTAL_WIDTH:
		# Calculate required space reduction
		var excess_width := total_width - MAX_TOTAL_WIDTH
		var required_space_per_gap := excess_width / (number_of_cards - 1)
		card_space = DEFAULT_CARD_SPACE - required_space_per_gap
	var center := _container.size/2
	var start_x := center.x - (number_of_cards * _card_size + card_space * (number_of_cards - 1)) / 2
	var result:Array[Vector2] = []
	var target_y = _container.size.y - GUIToolCardButton.SIZE.y
	for i in number_of_cards:
		var target_position := Vector2(start_x + i*_card_size + i*card_space, target_y)
		result.append(target_position)
	result.reverse() # First card is at the end of the array.
	for i in result.size():
		if selected_index >= 0:
			if card_space < 0.0:
				var pos = result[i]
				if i < selected_index:
					# The positions are reversed
					pos.x += 1 - card_space # Push right cards 4 pixels left
				elif i > selected_index:
					pos.x -= 1 - card_space # Push left cards 4 pixels right
				result[i] = pos
	return result

#region private

func _handle_selected_card(card:GUIToolCardButton) -> void:
	if card.card_state == GUIToolCardButton.CardState.SELECTED:
		return
	card.card_state = GUIToolCardButton.CardState.SELECTED
	tool_selected.emit(card.tool_data)

func _hide_all_warnings() -> void:
	Singletons.main_game.hide_warning(WarningManager.WarningType.INSUFFICIENT_ENERGY)
	Singletons.main_game.hide_warning(WarningManager.WarningType.DIALOGUE_CANNOT_USE_CARD)
	Singletons.main_game.hide_warning(WarningManager.WarningType.CARD_USE_LIMIT_REACHED)

func _return_secondary_card_to_hand(card:GUIToolCardButton) -> void:
	_card_selection_container.remove_selected_secondary_card(card)
	var default_position := calculate_default_positions(_container.get_children().size())[card.hand_index]
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(card, "position", default_position, REPOSITION_DURATION)
	await tween.finished

#endregion

#region events

func _on_tool_card_pressed(index:int) -> void:
	_hide_all_warnings()
	var selected_card:GUIToolCardButton = _container.get_child(index)
	if card_selection_mode:
		if _card_selection_container.is_selected_secondary_card(selected_card):
			_return_secondary_card_to_hand(selected_card)
		elif _card_selection_container.is_card_selection_full():
			var card_to_remove_index := _card_selection_container.selected_secondary_cards.size() - 1
			var card_to_remove:GUIToolCardButton = _card_selection_container.selected_secondary_cards[card_to_remove_index]
			_return_secondary_card_to_hand(card_to_remove)
			_card_selection_container.select_secondary_card(selected_card)
		else:
			_card_selection_container.select_secondary_card(selected_card)
		return
	# Select a main card from hand.
	if selected_card.tool_data.get_final_energy_cost() < 0:
		selected_card.play_error_shake_animation()
		Singletons.main_game.show_warning(WarningManager.WarningType.DIALOGUE_CANNOT_USE_CARD)
		return
	if card_use_limit_reached:
		selected_card.play_error_shake_animation()
		Singletons.main_game.show_warning(WarningManager.WarningType.CARD_USE_LIMIT_REACHED)
		return
	selected_index = index
	
	var positions:Array[Vector2] = calculate_default_positions(_container.get_children().size())
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		gui_card.position = positions[i]
	if selected_card.resource_sufficient:
		for i in _container.get_children().size():	
			var gui_card:GUIToolCardButton = _container.get_child(i)
			if i == index:
				_handle_selected_card(gui_card)
			else:
				assert(!card_selection_mode)
				gui_card.card_state = GUIToolCardButton.CardState.UNSELECTED
	else:
		selected_index = -1
		selected_card.play_error_shake_animation()
		Singletons.main_game.show_warning(WarningManager.WarningType.INSUFFICIENT_ENERGY)

func _on_tool_card_mouse_entered(index:int) -> void:
	_hide_all_warnings()
	var mouse_over_card = _container.get_child(index)
	if !is_instance_valid(mouse_over_card):
		return
	if mouse_over_card.card_state == GUIToolCardButton.CardState.NORMAL || mouse_over_card.card_state == GUIToolCardButton.CardState.UNSELECTED:
		mouse_over_card.card_state = GUIToolCardButton.CardState.HIGHLIGHTED
	if selected_index >= 0:
		return
	var positions:Array[Vector2] = calculate_default_positions(_container.get_children().size())
	if positions.size() < 2:
		return
	var card_padding := positions[0].x - positions[1].x - _card_size
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.01)
	var animated := false
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		if card_padding < 0.0:
			var pos = positions[i]
			if i < index:
				# The positions are reversed
				pos.x += 1 - card_padding # Push right cards 4 pixels left
			elif i > index:
				pos.x -= 1 - card_padding # Push left cards 4 pixels right
			tween.tween_property(gui_card, "position", pos, REPOSITION_DURATION)
			animated = true
	if !animated:
		tween.kill()

func _on_tool_card_mouse_exited(index:int) -> void:
	_hide_all_warnings()
	var mouse_exit_card = _container.get_child(index)
	if !is_instance_valid(mouse_exit_card):
		return
	if mouse_exit_card.card_state == GUIToolCardButton.CardState.HIGHLIGHTED:
		if selected_index >= 0 && !card_selection_mode:
			mouse_exit_card.card_state = GUIToolCardButton.CardState.UNSELECTED
		else:
			mouse_exit_card.card_state = GUIToolCardButton.CardState.NORMAL
	if selected_index >= 0:
		return
	var positions:Array[Vector2] = calculate_default_positions(_container.get_children().size())
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.01)
	var animated := false
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		tween.tween_property(gui_card, "position", positions[i], REPOSITION_DURATION)
		animated = true
	if !animated:
		tween.kill()

func _on_tool_card_use_card_button_pressed(tool_data:ToolData) -> void:
	card_use_button_pressed.emit(tool_data)

#endregion

#region setters/getters

func _set_card_use_limit_reached(value:bool) -> void:
	card_use_limit_reached = value
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		gui_card.disabled = value

func _set_card_selection_mode(val:bool) -> void:
	card_selection_mode = val
	for i in _container.get_children().size():
		var gui_card:GUIToolCardButton = _container.get_child(i)
		if i == selected_index:
			gui_card.card_state = GUIToolCardButton.CardState.WAITING
		else:
			gui_card.card_state = GUIToolCardButton.CardState.NORMAL
#endregion
