class_name Player
extends Node2D

const MOVE_TIME := 0.1

enum MoveDirection {
	LEFT,
	RIGHT
}

signal move_buttons_pressed(move_direction:MoveDirection)

const POSITION_Y_OFFSET := -56

@onready var player_sprite: AnimatedSprite2D = %PlayerSprite
@onready var player_state_machine: PlayerStateMachine = %PlayerStateMachine
@onready var left_button: GUIImageButton = %LeftButton
@onready var right_button: GUIImageButton = %RightButton
@onready var move_indicator: Label = %MoveIndicator
@onready var move_ui: Control = %MoveUI

var moves_left:int = 0: set = _set_moves_left

func _ready() -> void:
	player_state_machine.start()
	left_button.pressed.connect(_on_button_pressed.bind(MoveDirection.LEFT))
	right_button.pressed.connect(_on_button_pressed.bind(MoveDirection.RIGHT))

func toggle_move_buttons(on:bool) -> void:
	left_button.button_state = GUIBasicButton.ButtonState.NORMAL if on else GUIBasicButton.ButtonState.DISABLED
	right_button.button_state = GUIBasicButton.ButtonState.NORMAL if on else GUIBasicButton.ButtonState.DISABLED

func move_to_x(x: float) -> void:
	moves_left -= 1
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(x, POSITION_Y_OFFSET), MOVE_TIME).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _on_button_pressed(move_direction:MoveDirection) -> void:
	move_buttons_pressed.emit(move_direction)
	moves_left -= 1

func _set_moves_left(value:int) -> void:
	moves_left = max(value, 0)
	move_indicator.text = str(moves_left)
	assert(moves_left >= 0)
	move_ui.visible = moves_left > 0
