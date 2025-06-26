class_name GUIToolHandContainer
extends PanelContainer

signal tool_selected(index:int)

const TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const DEFAULT_CARD_SPACE := 4.0
const MAX_TOTAL_WIDTH := 150

@onready var _hover_sound: AudioStreamPlayer2D = %HoverSound
@onready var _container: Control = %Container

var _card_size:int

func _ready() -> void:
	var temp_tool_card := TOOL_CARD_SCENE.instantiate()
	_card_size = temp_tool_card.size.x
	temp_tool_card.queue_free()

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

func update_with_tool_datas(tools:Array[ToolData]) -> void:
	var current_size :=  _container.get_children().size()
	var positions := calculate_default_positions(tools.size() + current_size)
	for i in positions.size():
		var gui_card:GUIToolCardButton = TOOL_CARD_SCENE.instantiate()
		gui_card.state_updated.connect(_on_card_state_updated.bind(i))
		gui_card.action_evoked.connect(_on_card_action_evoked.bind(i))
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
	return result

func _on_card_state_updated(button_state:GUIBasicButton.ButtonState, index:int) -> void:
	var card_highlighted := button_state == GUIBasicButton.ButtonState.HOVERED
	var positions:Array[Vector2] = calculate_default_positions(_container.get_children().size())
	if positions.size() < 2:
		return
	var card_padding := positions[0].x - positions[1].x - _card_size
	if card_highlighted:
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
				if i == index:
					gui_card.container_offset = -1.0
				else:
					gui_card.container_offset = 0.0
	else:
		# Reset to default positions
		for i in _container.get_children().size():
			var gui_card = _container.get_child(i)
			gui_card.position = positions[i]

func _on_card_action_evoked(index:int) -> void:
	for i in _container.get_children().size():
		var gui_card = _container.get_child(i)
		if i == index:
			gui_card.button_state = GUIBasicButton.ButtonState.SELECTED
			gui_card.container_offset = -4.0
		else:
			gui_card.button_state = GUIBasicButton.ButtonState.DISABLED
			gui_card.container_offset = 0.0
	tool_selected.emit(index)
