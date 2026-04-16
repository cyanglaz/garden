class_name GUIToolCardContainer
extends Control

signal main_card_selected(tool_data:ToolData)
signal mouse_exited_card(tool_data:ToolData)

var TOOL_CARD_SCENE := load("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")

const DEFAULT_CARD_SPACE := 1.0
const MAX_TOTAL_WIDTH := 200
const REPOSITION_DURATION:float = 0.08
const TOOL_SELECTED_OFFSET := -6.0
const CARD_SELECTION_READY_TIME := 0.2

@onready var _container: Control = %Container
@onready var _gui_tool_card_animation_container: GUIToolCardAnimationContainer = %GUIToolCardAnimationContainer
@onready var _card_selection_container: GUICardSelectionContainer = %CardSelectionContainer

var _card_size:float
var card_use_limit_reached:bool = false: set = _set_card_use_limit_reached
var card_selection_mode := false
var is_mid_turn:bool = false
var _secondary_card_selection_main_card:GUIToolCardButton = null
var _secondary_card_selection_candidates:Array = []
var _selected_secondary_cards:Array[GUIToolCardButton] = []
var _tool_card_interaction_enabled:bool = true
var _last_selected_main_card_index:int = -1

func _ready() -> void:
	_card_size = GUIToolCardButton.SIZE.x
	_card_selection_container.hide()

func setup(draw_box_button:GUIDeckButton, discard_box_button:GUIDeckButton) -> void:
	_gui_tool_card_animation_container.setup(self, draw_box_button, discard_box_button)
	
func clear_selection() -> void:
	_last_selected_main_card_index = -1
	_clear_secondary_card_selection()
	Events.request_hide_warning.emit(WarningManager.WarningType.INSUFFICIENT_ENERGY)
	Events.request_hide_warning.emit(WarningManager.WarningType.DIALOGUE_CANNOT_USE_CARD)
	Events.request_hide_warning.emit(WarningManager.WarningType.CARD_USE_LIMIT_REACHED)

func reset_positions() -> void:
	var positions:Array[Vector2] = calculate_default_positions(_container.get_children().size())
	if positions.size() > 0:
		var tween:Tween = Util.create_scaled_tween(self)
		tween.set_parallel(true)
		for i in _container.get_children().size():
			var gui_card = _container.get_child(i)
			if gui_card.card_state != GUICardFace.CardState.WAITING:
				gui_card.card_state = GUICardFace.CardState.NORMAL
			tween.tween_property(gui_card, "position", positions[i], REPOSITION_DURATION)
		await tween.finished
		for i in _container.get_children().size():
			var gui_card = _container.get_child(i)
			gui_card.z_index = 0

func end_turn_reset_all() -> void:
	clear_selection()
	var positions:Array[Vector2] = calculate_default_positions(_container.get_children().size())
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		gui_card.card_state = GUICardFace.CardState.NORMAL
		gui_card.position = positions[i]
		gui_card.z_index = 0

func add_card(tool_data:ToolData, combat_main:CombatMain) -> GUIToolCardButton:
	var gui_card:GUIToolCardButton = TOOL_CARD_SCENE.instantiate()
	_container.add_child(gui_card)
	gui_card.update_with_tool_data(tool_data, combat_main)
	gui_card.card_state = GUICardFace.CardState.NORMAL
	_rebind_signals()
	gui_card.disabled = card_use_limit_reached
	gui_card.mouse_disabled = !_tool_card_interaction_enabled
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
		if card.tool_data.back_card == tool_data:
			return card
		if card.tool_data.front_card == tool_data:
			return card
	return null

func select_secondary_cards(number_of_cards:int, candidates:Array) -> Array:
	_secondary_card_selection_candidates = candidates
	_toggle_card_selection_mode(true)
	var cards_enabled:bool = _tool_card_interaction_enabled
	_toggle_selected_cards( true)
	var result := await _card_selection_container.start_selection(number_of_cards, _secondary_card_selection_candidates)
	if !cards_enabled:
		_toggle_selected_cards(false)
	_clear_secondary_card_selection()
	return result

func play_card_error_shake_animation(tool_data:ToolData) -> void:
	var card:GUIToolCardButton = find_card(tool_data)
	card.play_error_shake_animation()
	Events.request_show_warning.emit(WarningManager.WarningType.INSUFFICIENT_ENERGY)

func select_main_card(tool_data:ToolData) -> bool:
	# Select a main card from hand.
	var selected_card:GUIToolCardButton = find_card(tool_data)
	if tool_data.get_final_energy_cost() < 0:
		selected_card.play_error_shake_animation()
		Events.request_show_warning.emit(WarningManager.WarningType.DIALOGUE_CANNOT_USE_CARD)
		return false
	if card_use_limit_reached:
		selected_card.play_error_shake_animation()
		Events.request_show_warning.emit(WarningManager.WarningType.CARD_USE_LIMIT_REACHED)
		return false
	
	_last_selected_main_card_index = selected_card.hand_index
	var positions:Array[Vector2] = calculate_default_positions(_container.get_children().size())
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		gui_card.position = positions[i]
	if selected_card.resource_sufficient:
		_handle_selected_card(selected_card)
		return true
	else:
		_last_selected_main_card_index = -1
		selected_card.play_error_shake_animation()
		Events.request_show_warning.emit(WarningManager.WarningType.INSUFFICIENT_ENERGY)
		return false

#region animation

func animate_draw(draw_results:Array, combat_main:CombatMain) -> void:
	await _gui_tool_card_animation_container.animate_draw(draw_results, combat_main)
	
func animate_discard(discarding_tool_datas:Array, combat_main:CombatMain) -> void:
	await _gui_tool_card_animation_container.animate_discard(discarding_tool_datas, combat_main)

func animate_shuffle(discard_pile:Array, combat_main:CombatMain) -> void:
	await _gui_tool_card_animation_container.animate_shuffle(discard_pile, combat_main)

func animate_add_cards_to_draw_pile(tool_datas:Array, from_global_position:Vector2, pause:bool, combat_main:CombatMain) -> void:
	await _gui_tool_card_animation_container.animate_add_cards_to_draw_pile(tool_datas, from_global_position, pause, combat_main)

func animate_add_cards_to_discard_pile(tool_datas:Array, from_global_position:Vector2, pause:bool, combat_main:CombatMain) -> void:
	await _gui_tool_card_animation_container.animate_add_cards_to_discard_pile(tool_datas, from_global_position, pause, combat_main)

func animate_stash_card_to_draw_pile(tool_data: ToolData, from_position: Vector2, combat_main:CombatMain) -> void:
	await _gui_tool_card_animation_container.animate_stash_card_to_draw_pile(tool_data, from_position, combat_main)

func animate_add_cards_to_hand(hand:Array, tool_datas:Array, from_global_position:Vector2, pause:bool, combat_main:CombatMain) -> void:
	await _gui_tool_card_animation_container.animate_add_cards_to_hand(hand, tool_datas, from_global_position, pause, combat_main)

func animate_exhaust(tool_datas:Array, combat_main:CombatMain) -> void:
	await _gui_tool_card_animation_container.animate_exhaust(tool_datas, combat_main)

func animate_card_error_shake(tool_data:ToolData) -> void:
	var card:GUIToolCardButton = find_card(tool_data)
	await card.play_error_shake_animation()

#endregion

func set_card_state(tool_data:ToolData, state:GUICardFace.CardState) -> void:
	var card:GUIToolCardButton = find_card(tool_data)
	card.card_state = state

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
	#result.reverse() # First card is at the end of the array.
	for i in result.size():
		if _last_selected_main_card_index >= 0:
			if card_space < 0.0:
				var pos = result[i]
				if i < _last_selected_main_card_index:
					pos.x -= 1 - card_space # Push left cards 4 pixels left
				elif i > _last_selected_main_card_index:
					pos.x += 1 - card_space # Push right cards 4 pixels right
				result[i] = pos
	return result

#region private
func _get_card_index(tool_data:ToolData) -> int:
	for i in _container.get_children().size():
		var card:GUIToolCardButton = _container.get_child(i)
		if card.tool_data == tool_data:
			return i
		if card.tool_data.back_card == tool_data:
			return i
		if card.tool_data.front_card == tool_data:
			return i
	return -1

func _toggle_selected_cards(on:bool) -> void:
	for tool_data in _secondary_card_selection_candidates:
		var gui_card:GUIToolCardButton = find_card(tool_data)
		gui_card.mouse_disabled = !on

func _clear_secondary_card_selection() -> void:
	_card_selection_container.end_selection()
	_selected_secondary_cards.clear()
	_toggle_card_selection_mode(false)

func _toggle_card_selection_mode(on:bool) -> void:
	card_selection_mode = on
	if !card_selection_mode:
		_secondary_card_selection_candidates.clear()
	for gui_card:GUIToolCardButton in get_all_cards():
		if card_selection_mode:
			if gui_card == _secondary_card_selection_main_card:
				gui_card.card_state = GUICardFace.CardState.SELECTED
			elif _secondary_card_selection_candidates.has(gui_card.tool_data):
				gui_card.card_state = GUICardFace.CardState.NORMAL
			else:
				gui_card.card_state = GUICardFace.CardState.UNSELECTED
		else:
			if gui_card.card_state != GUICardFace.CardState.WAITING:
				gui_card.card_state = GUICardFace.CardState.NORMAL

func _rebind_signals() -> void:
	for i in _container.get_children().size():
		var gui_card:GUIToolCardButton = _container.get_child(i)
		if gui_card.pressed.is_connected(_on_tool_card_pressed):
			gui_card.pressed.disconnect(_on_tool_card_pressed)
		if gui_card.mouse_entered_card.is_connected(_on_tool_card_mouse_entered):
			gui_card.mouse_entered_card.disconnect(_on_tool_card_mouse_entered)
		if gui_card.mouse_exited_card.is_connected(_on_tool_card_mouse_exited):
			gui_card.mouse_exited_card.disconnect(_on_tool_card_mouse_exited)
		gui_card.pressed.connect(_on_tool_card_pressed.bind(i))
		gui_card.mouse_entered_card.connect(_on_tool_card_mouse_entered.bind(i))
		gui_card.mouse_exited_card.connect(_on_tool_card_mouse_exited.bind(i))
		gui_card.hand_index = i

func _handle_selected_card(card:GUIToolCardButton) -> void:
	if card.card_state == GUICardFace.CardState.WAITING \
	or card.card_state == GUICardFace.CardState.SELECTED:
		return
	card.card_state = GUICardFace.CardState.WAITING

func _hide_all_card_warnings() -> void:
	for warning_type in [WarningManager.WarningType.DIALOGUE_CANNOT_USE_CARD, \
						WarningManager.WarningType.CARD_USE_LIMIT_REACHED, \
						WarningManager.WarningType.INSUFFICIENT_ENERGY]:
			Events.request_hide_warning.emit(warning_type)

func _return_secondary_card_to_hand(card:GUIToolCardButton) -> void:
	_card_selection_container.remove_selected_secondary_card(card)
	var default_position := calculate_default_positions(_container.get_children().size())[card.hand_index]
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(card, "position", default_position, REPOSITION_DURATION)
	await tween.finished

#endregion

#region events

func _on_tool_card_pressed(index:int) -> void:
	if !is_mid_turn:
		return
	_hide_all_card_warnings()
	var selected_card:GUIToolCardButton = _container.get_child(index)
	if card_selection_mode:
		if selected_card == _secondary_card_selection_main_card:
			return
		_secondary_card_selection_main_card = selected_card
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
	else:
		_secondary_card_selection_main_card = null
	main_card_selected.emit(selected_card.tool_data)

func _on_tool_card_mouse_entered(index:int) -> void:
	_hide_all_card_warnings()
	var mouse_over_card = _container.get_child(index)
	if !is_instance_valid(mouse_over_card):
		return
	if _last_selected_main_card_index >= 0:
		return
	if card_selection_mode:
		return
	var positions:Array[Vector2] = calculate_default_positions(_container.get_children().size())
	if positions.size() < 2:
		return
	var card_padding := positions[1].x - positions[0].x - _card_size
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.01)
	var animated := false
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		if gui_card.mouse_disabled:
			continue
		if card_padding < 0.0:
			var pos = positions[i]
			if i < index:
				pos.x -= 1 - card_padding # Push left cards 4 pixels left
			elif i > index:
				pos.x += 1 - card_padding # Push left cards 4 pixels right
			tween.tween_property(gui_card, "position", pos, REPOSITION_DURATION)
			animated = true
	if !animated:
		tween.kill()

func _on_tool_card_mouse_exited(index:int) -> void:
	_hide_all_card_warnings()
	var mouse_exit_card = _container.get_child(index)
	mouse_exited_card.emit(mouse_exit_card.tool_data)
	if !is_instance_valid(mouse_exit_card):
		return
	if card_selection_mode:
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
		if gui_card.mouse_disabled:
			continue
		tween.tween_property(gui_card, "position", positions[i], REPOSITION_DURATION)
		animated = true
	if !animated:
		tween.kill()

#endregion

#region setters/getters

func _set_card_use_limit_reached(value:bool) -> void:
	card_use_limit_reached = value
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		gui_card.disabled = value

#endregion
