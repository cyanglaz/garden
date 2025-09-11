class_name GUILibraryTopBar
extends HBoxContainer

signal top_bar_button_evoked(data:ThingData)

const TOP_BAR_BUTTON := preload("res://scenes/GUI/controls/buttons/gui_library_top_bar_button.tscn")

func add_top_bar_button(data:ThingData) -> void:
	var top_bar_button:GUILibraryTopBarButton = TOP_BAR_BUTTON.instantiate()
	add_child(top_bar_button)
	top_bar_button.update_with_data(data)
	top_bar_button.top_bar_button_evoked.connect(_on_top_bar_button_evoked.bind(top_bar_button))
	_select_button(top_bar_button)

func _on_top_bar_button_evoked(data:ThingData, top_bar_button:GUILibraryTopBarButton) -> void:
	_select_button(top_bar_button)
	top_bar_button_evoked.emit(data)

func _select_button(top_bar_button:GUILibraryTopBarButton) -> void:
	for child:GUILibraryTopBarButton in get_children():
		if child == top_bar_button:
			child.button_state = GUILibraryTopBarButton.ButtonState.SELECTED
		else:
			child.button_state = GUILibraryTopBarButton.ButtonState.NORMAL
