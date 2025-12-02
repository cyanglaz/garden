class_name GUICombatView
extends Control

@onready var gui_combat: GUICombat = %GUICombat

@onready var _back_button: GUIRichTextButton = %BackButton

func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_pressed)

func show_with_combat_data(combat_data:CombatData) -> void:
	gui_combat.update_with_combat_data(combat_data)
	show()

func _on_back_button_pressed() -> void:
	hide()
