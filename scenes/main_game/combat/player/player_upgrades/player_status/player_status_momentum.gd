class_name PlayerStatusMomentum
extends PlayerStatus

enum MoveDirection {
	LEFT,
	RIGHT
}

signal button_pressed(move_direction:MoveDirection)

@onready var move_ui: Control = %MoveUI
@onready var left_button: GUIImageButton = %LeftButton
@onready var right_button: GUIImageButton = %RightButton

func _ready() -> void:
	left_button.pressed.connect(_on_button_pressed.bind(MoveDirection.LEFT))
	right_button.pressed.connect(_on_button_pressed.bind(MoveDirection.RIGHT))

func update_current_field_index(index:int, max_plants_index:int) -> void:
	assert(max_plants_index > 0)
	if index == 0:
		left_button.hide()
	else:
		left_button.show()
	if index == max_plants_index:
		right_button.hide()
	else:
		right_button.show()

func _toggle_ui_buttons(on:bool) -> void:
	left_button.button_state = GUIBasicButton.ButtonState.NORMAL if on else GUIBasicButton.ButtonState.DISABLED
	right_button.button_state = GUIBasicButton.ButtonState.NORMAL if on else GUIBasicButton.ButtonState.DISABLED

func _on_left_button_pressed() -> void:
	Events.request_movement_update.emit(-1, ActionData.OperatorType.DECREASE)

func _on_right_button_pressed() -> void:
	Events.request_movement_update.emit(1, ActionData.OperatorType.INCREASE)

func _on_button_pressed(move_direction:MoveDirection) -> void:
	button_pressed.emit(move_direction)
