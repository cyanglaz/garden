class_name Field
extends Node2D

signal field_pressed()

@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _gui_field_button: GUIBasicButton = %GUIFieldButton

func _ready() -> void:
	_gui_field_button.state_updated.connect(_on_gui_field_button_state_updated)
	_gui_field_button.action_evoked.connect(func(): field_pressed.emit())
	_animated_sprite_2d.play("idle")

func _on_gui_field_button_state_updated(state: GUIBasicButton.ButtonState) -> void:
	match state:
		GUIBasicButton.ButtonState.NORMAL, GUIBasicButton.ButtonState.DISABLED, GUIBasicButton.ButtonState.SELECTED:
			_animated_sprite_2d.play("idle")
		GUIBasicButton.ButtonState.HOVERED:
			_animated_sprite_2d.play("hover")
		GUIBasicButton.ButtonState.PRESSED:
			_animated_sprite_2d.play("pressed")
