class_name GUICardPlaceHolder
extends PanelContainer

signal button_pressed()
signal button_hovered(hovered:bool)

@onready var gui_basic_button: GUIBasicButton = %GUIBasicButton

var button_enabled:= false: set = _set_button_enabled

func _ready() -> void:
	_set_button_enabled(button_enabled)
	gui_basic_button.pressed.connect(_on_gui_basic_button_pressed)
	gui_basic_button.mouse_entered.connect(_on_gui_basic_button_mouse_entered)
	gui_basic_button.mouse_exited.connect(_on_gui_basic_button_mouse_exited)

func _set_button_enabled(val:bool) -> void:
	button_enabled = val
	if gui_basic_button:
		if button_enabled:
			gui_basic_button.button_state = GUIBasicButton.ButtonState.NORMAL
		else:
			gui_basic_button.button_state = GUIBasicButton.ButtonState.DISABLED

func _on_gui_basic_button_pressed() -> void:
	button_pressed.emit()

func _on_gui_basic_button_mouse_entered() -> void:
	button_hovered.emit(true)

func _on_gui_basic_button_mouse_exited() -> void:
	button_hovered.emit(false)
