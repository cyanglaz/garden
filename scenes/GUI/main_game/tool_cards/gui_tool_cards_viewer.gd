class_name GUIToolCardsViewer
extends Control

const MAX_SCROLL_SIZE_Y := 128
const TOOL_CARD_BUTTON_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")

@onready var _grid_container: GridContainer = %GridContainer
@onready var _scroll_container: ScrollContainer = %ScrollContainer
@onready var _back_button: GUIRichTextButton = %BackButton

func _ready() -> void:
	_back_button.action_evoked.connect(_on_back_button_evoked)

func animated_show_with_pool(pool:Array) -> void:
	get_tree().paused = true
	show()
	Util.remove_all_children(_grid_container)
	var card_size := Vector2.ONE
	for tool_data in pool:
		var gui_tool_card: GUIToolCardButton = TOOL_CARD_BUTTON_SCENE.instantiate()
		_grid_container.add_child(gui_tool_card)
		gui_tool_card.size = gui_tool_card.custom_minimum_size
		gui_tool_card.update_with_tool_data(tool_data)
		card_size = gui_tool_card.size
	@warning_ignore("integer_division")
	var rows := pool.size()/_grid_container.columns
	var v_seperation:int = _grid_container.get_theme_constant("v_separation")
	var content_height:float = rows * (card_size.y + v_seperation) - v_seperation
	if content_height > MAX_SCROLL_SIZE_Y:
		_scroll_container.custom_minimum_size.y = MAX_SCROLL_SIZE_Y
		_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	else:
		_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_scroll_container.custom_minimum_size.y = 0

func animate_hide() -> void:
	hide()

func _on_back_button_evoked() -> void:
	animate_hide()
	get_tree().paused = false
