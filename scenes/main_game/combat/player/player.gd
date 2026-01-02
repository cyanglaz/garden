class_name Player
extends Node2D

const POSITION_Y_OFFSET := -56

@onready var player_sprite: AnimatedSprite2D = %PlayerSprite
@onready var player_state_machine: PlayerStateMachine = %PlayerStateMachine

func _ready() -> void:
	player_state_machine.start()

func move_to_x(x: float) -> void:
	global_position.x = x
	global_position.y = POSITION_Y_OFFSET
