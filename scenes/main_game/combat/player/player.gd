class_name Player
extends Node2D

signal field_index_updated(index:int)

const MOVE_TIME := 0.1

enum MoveDirection {
	LEFT,
	RIGHT
}

const POSITION_Y_OFFSET := -38

@onready var player_sprite: AnimatedSprite2D = %PlayerSprite
@onready var player_state_machine: PlayerStateMachine = %PlayerStateMachine
@onready var left_button: GUIImageButton = %LeftButton
@onready var right_button: GUIImageButton = %RightButton
@onready var move_indicator: Label = %MoveIndicator
@onready var move_ui: Control = %MoveUI

var moves_left:int = 0: set = _set_moves_left
var current_field_index:int = 0: set = _set_current_field_index
var max_plants_index:int = 0

func _ready() -> void:
	player_state_machine.start()
	left_button.pressed.connect(_on_button_pressed.bind(MoveDirection.LEFT))
	right_button.pressed.connect(_on_button_pressed.bind(MoveDirection.RIGHT))

func toggle_move_buttons(on:bool) -> void:
	left_button.button_state = GUIBasicButton.ButtonState.NORMAL if on else GUIBasicButton.ButtonState.DISABLED
	right_button.button_state = GUIBasicButton.ButtonState.NORMAL if on else GUIBasicButton.ButtonState.DISABLED

func move_to_x(x: float) -> void:
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(x, POSITION_Y_OFFSET), MOVE_TIME).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _on_button_pressed(move_direction:MoveDirection) -> void:
	match move_direction:
		MoveDirection.LEFT:
			current_field_index -= 1
		MoveDirection.RIGHT:
			current_field_index += 1
	moves_left -= 1

func _set_moves_left(value:int) -> void:
	moves_left = max(value, 0)
	move_indicator.text = str(moves_left)
	assert(moves_left >= 0)
	move_ui.visible = moves_left > 0

func _set_current_field_index(value:int) -> void:
	current_field_index = value
	if current_field_index == 0:
		left_button.hide()
	else:
		left_button.show()
	if current_field_index == max_plants_index:
		right_button.hide()
	else:
		right_button.show()
	field_index_updated.emit(current_field_index)
