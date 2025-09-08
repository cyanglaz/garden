class_name GUIToolCardContainer
extends PanelContainer

signal tool_selected(index:int)

const TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const DEFAULT_CARD_SPACE := 1.0
const MAX_TOTAL_WIDTH := 200
const REPOSITION_DURATION:float = 0.08
const TOOL_SELECTED_OFFSET := -6.0

@onready var _container: Control = %Container
@onready var _gui_tool_card_animation_container: GUIToolCardAnimationContainer = %GUIToolCardAnimationContainer

var _card_size:int
var _weak_insufficient_energy_tooltip:WeakRef = weakref(null)
var _selected_index:int = -1

func _ready() -> void:
	var temp_tool_card := TOOL_CARD_SCENE.instantiate()
	_card_size = temp_tool_card.size.x
	temp_tool_card.queue_free()

func setup(draw_box_button:GUIDeckButton, discard_box_button:GUIDeckButton) -> void:
	_gui_tool_card_animation_container.setup(self, draw_box_button, discard_box_button)

func toggle_all_tool_cards(on:bool) -> void:
	for i in get_card_count():
		var card:GUIToolCardButton = _container.get_child(i)
		card.mouse_disabled = !on

func clear() -> void:
	if _container.get_children().size() == 0:
		return
	for child:GUIToolCardButton in _container.get_children():
		child.queue_free()
	_clear_warning_tooltip()

func clear_selection() -> void:
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		gui_card.mouse_disabled = false
		gui_card.card_state = GUIToolCardButton.CardState.NORMAL
	_selected_index = -1
	_clear_warning_tooltip()

func add_card(tool_data:ToolData) -> GUIToolCardButton:
	var gui_card:GUIToolCardButton = TOOL_CARD_SCENE.instantiate()
	_container.add_child(gui_card)
	gui_card.update_with_tool_data(tool_data)
	gui_card.activated = true
	_rebind_signals()
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
		if card._tool_data == tool_data:
			return card
	return null

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

#region animation

func animate_draw(draw_results:Array) -> void:
	await _gui_tool_card_animation_container.animate_draw(draw_results)
	
func animate_discard(discarding_tool_datas:Array) -> void:
	await _gui_tool_card_animation_container.animate_discard(discarding_tool_datas)

func animate_use_card(tool_data:ToolData) -> void:
	await _gui_tool_card_animation_container.animate_use_card(tool_data)

func animate_shuffle(number_of_cards:int) -> void:
	await _gui_tool_card_animation_container.animate_shuffle(number_of_cards)

func animate_add_card_to_draw_pile(tool_data:ToolData, from_global_position:Vector2, pause:bool) -> void:
	await _gui_tool_card_animation_container.animate_add_card_to_draw_pile(tool_data, from_global_position, pause)

func animate_add_card_to_deck(tool_data:ToolData, from_global_position:Vector2) -> void:
	await _gui_tool_card_animation_container.animate_add_card_to_deck(tool_data, from_global_position)

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
	for i in number_of_cards:
		var target_position := Vector2(start_x + i*_card_size + i*card_space, 0)
		result.append(target_position)
	result.reverse() # First card is at the end of the array.
	for i in result.size():
		if _selected_index >= 0:
			if card_space < 0.0:
				var pos = result[i]
				if i < _selected_index:
					# The positions are reversed
					pos.x += 1 - card_space # Push right cards 4 pixels left
				elif i > _selected_index:
					pos.x -= 1 - card_space # Push left cards 4 pixels right
				result[i] = pos
	return result

#region private

func _clear_warning_tooltip() -> void:
	if _weak_insufficient_energy_tooltip.get_ref():
		_weak_insufficient_energy_tooltip.get_ref().queue_free()
		_weak_insufficient_energy_tooltip = weakref(null)

#endregion

#region events

func _on_tool_card_pressed(index:int) -> void:
	_clear_warning_tooltip()
	var selected_card:GUIToolCardButton = _container.get_child(index)
	_selected_index = index
	var positions:Array[Vector2] = calculate_default_positions(_container.get_children().size())
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		gui_card.position = positions[i]
	if selected_card.resource_sufficient:
		for i in _container.get_children().size():	
			var gui_card = _container.get_child(i)
			if i == index:
				if gui_card.card_state != GUIToolCardButton.CardState.SELECTED:
					gui_card.card_state = GUIToolCardButton.CardState.SELECTED
					tool_selected.emit(index)
			else:
				gui_card.card_state = GUIToolCardButton.CardState.NORMAL
	else:
		_weak_insufficient_energy_tooltip = weakref(Util.display_warning_tooltip(tr("WARNING_INSUFFICIENT_ENERGY"), selected_card, false, GUITooltip.TooltipPosition.TOP))

func _on_tool_card_mouse_entered(index:int) -> void:
	_clear_warning_tooltip()
	var mouse_over_card = _container.get_child(index)
	if !is_instance_valid(mouse_over_card):
		return
	if mouse_over_card.card_state == GUIToolCardButton.CardState.NORMAL:
		mouse_over_card.card_state = GUIToolCardButton.CardState.HIGHLIGHTED
	if _selected_index >= 0:
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
	_clear_warning_tooltip()
	var mouse_exit_card = _container.get_child(index)
	if !is_instance_valid(mouse_exit_card):
		return
	if mouse_exit_card.card_state == GUIToolCardButton.CardState.HIGHLIGHTED:
		mouse_exit_card.card_state = GUIToolCardButton.CardState.NORMAL
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
