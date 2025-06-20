@tool
class_name GUITabControl
extends PanelContainer

signal tab_selected(index:int)

@export var tab_options_scene:PackedScene
@export var number_of_tabs:int: set = _set_number_of_tabs
@export var tab_localization_titles:Array[String]: set = _set_tab_localization_titles

@onready var _buttons_container: HBoxContainer = %ButtonsContainer

func _ready() -> void:
	_set_number_of_tabs(number_of_tabs)
	_set_tab_localization_titles(tab_localization_titles)

func _set_tab_localization_titles(val:Array[String]) -> void:
	tab_localization_titles = val
	assert(val.size() <= number_of_tabs)
	if _buttons_container:
		var index := 0
		for title:String in val:
			_buttons_container.get_child(index).localization_text_key = title
			index += 1
		if _buttons_container.get_child_count() > 0:
			_select_button(0)

func _set_number_of_tabs(val:int) -> void:
	number_of_tabs = val
	if _buttons_container:
		Util.remove_all_children(_buttons_container)
		for index:int in range(val):
			var button:GUITabbarButton = tab_options_scene.instantiate()
			_buttons_container.add_child(button)
			button.action_evoked.connect(_on_tab_button_action_evoked.bind(index))

func _select_button(index:int) -> void:
	for button in _buttons_container.get_children():
		if button.get_index() == index:
			button.button_state = GUIBasicButton.ButtonState.SELECTED
		else:
			button.button_state = GUIBasicButton.ButtonState.NORMAL
	tab_selected.emit(index)

func _on_tab_button_action_evoked(index:int) -> void:
	_select_button(index)
