class_name GUIToolHandContainer
extends PanelContainer

signal tool_selected(index:int, tool_data:ToolData)

const TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const DEFAULT_CARD_SPACE := 4.0
const MAX_TOTAL_WIDTH := 150

@onready var _container: Control = %Container
@onready var _gui_tool_evoke_indicator: GUIToolEvokeIndicator = %GUIToolEvokeIndicator

var _card_size:int
var _tools:Array[ToolData]

func _ready() -> void:
	var temp_tool_card := TOOL_CARD_SCENE.instantiate()
	_card_size = temp_tool_card.size.x
	temp_tool_card.queue_free()

func show_tool_indicator(from_index:int) -> void:
	_gui_tool_evoke_indicator.show()
	var from_card :GUIToolCardButton = _container.get_child(from_index)
	var from_position := from_card.global_position + Vector2.RIGHT * from_card.size.x/2 + Vector2.UP * 4
	_gui_tool_evoke_indicator.from_position = from_position

func clear() -> void:
	if _container.get_children().size() == 0:
		return
	for child:GUIToolCardButton in _container.get_children():
		child.queue_free()

func clear_selection() -> void:
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		gui_card.button_state = GUIBasicButton.ButtonState.NORMAL
		gui_card.container_offset = 0.0
	_hide_tool_indicator()

func update_tool_for_time_left(time_left:int) -> void:
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		var tool_data:ToolData = _tools[i]
		if tool_data.time <= time_left:
			gui_card.button_state = GUIBasicButton.ButtonState.NORMAL
		else:
			gui_card.button_state = GUIBasicButton.ButtonState.DISABLED

func setup_with_tool_datas(tools:Array[ToolData]) -> void:
	Util.remove_all_children(_container)
	_tools = tools.duplicate()
	var current_size :=  _container.get_children().size()
	var positions := _calculate_default_positions(tools.size() + current_size)
	for i in positions.size():
		var gui_card:GUIToolCardButton = TOOL_CARD_SCENE.instantiate()
		gui_card.action_evoked.connect(_on_tool_card_action_evoked.bind(i, tools[i]))
		gui_card.mouse_entered.connect(_on_tool_card_mouse_entered.bind(i))
		gui_card.mouse_exited.connect(_on_tool_card_mouse_exited.bind(i))
		_container.add_child(gui_card)
		gui_card.update_with_tool_data(tools[i])
		gui_card.position = positions[i]

func get_card(index:int) -> GUIToolCardButton:
	return _container.get_child(index)

func get_card_count() -> int:
	return _container.get_children().size()

func get_card_position(index:int) -> Vector2:
	var gui_card:GUIToolCardButton = _container.get_child(index)
	return gui_card.global_position

func _calculate_default_positions(number_of_cards:int) -> Array[Vector2]:
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
	return result

func _hide_tool_indicator() -> void:
	_gui_tool_evoke_indicator.hide()

func _on_tool_card_action_evoked(index:int, tool_data:ToolData) -> void:
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		if i == index:
			gui_card.button_state = GUIBasicButton.ButtonState.SELECTED
			gui_card.container_offset = -4.0
		else:
			gui_card.button_state = GUIBasicButton.ButtonState.NORMAL
			gui_card.container_offset = 0.0
	tool_selected.emit(index, tool_data)

func _on_tool_card_mouse_entered(index:int) -> void:
	var mouse_over_card = _container.get_child(index)
	if mouse_over_card.button_state == GUIBasicButton.ButtonState.SELECTED || mouse_over_card.button_state == GUIBasicButton.ButtonState.DISABLED:
		return
	mouse_over_card.container_offset = -1.0
	var positions:Array[Vector2] = _calculate_default_positions(_container.get_children().size())
	if positions.size() < 2:
		return
	var card_padding := positions[0].x - positions[1].x - _card_size
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		if card_padding < 0.0:
			var pos = positions[i]
			if i < index:
				# The positions are reversed
				pos.x += 1 - card_padding # Push right cards 4 pixels left
			elif i > index:
				pos.x -= 1 - card_padding # Push left cards 4 pixels right
			gui_card.position = pos

func _on_tool_card_mouse_exited(index:int) -> void:
	var mouse_exit_card = _container.get_child(index)
	if mouse_exit_card.button_state == GUIBasicButton.ButtonState.SELECTED || mouse_exit_card.button_state == GUIBasicButton.ButtonState.DISABLED:
		return
	var positions:Array[Vector2] = _calculate_default_positions(_container.get_children().size())
	mouse_exit_card.container_offset = 0.0
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		gui_card.position = positions[i]
