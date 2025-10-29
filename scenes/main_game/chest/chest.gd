class_name Chest
extends Node2D

signal selected()

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var gui_basic_button: GUIBasicButton = %GUIBasicButton

func _ready() -> void:
	gui_basic_button.pressed.connect(_on_pressed)
	gui_basic_button.mouse_entered.connect(_on_mouse_entered)
	gui_basic_button.mouse_exited.connect(_on_mouse_exited)

func _on_pressed() -> void:
	animated_sprite_2d.play("open")
	selected.emit()

func _on_mouse_entered() -> void:
	animated_sprite_2d.material.set_shader_parameter("outline_size", 1)

func _on_mouse_exited() -> void:
	animated_sprite_2d.material.set_shader_parameter("outline_size", 0)
