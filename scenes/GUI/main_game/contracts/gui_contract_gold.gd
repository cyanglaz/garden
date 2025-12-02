class_name GUICombatGold
extends HBoxContainer

@onready var gui_outline_icon: GUIIcon = %GUIOutlineIcon
@onready var label: Label = %Label

func _ready() -> void:
	mouse_entered.connect(func() -> void: gui_outline_icon.has_outline = true)
	mouse_exited.connect(func() -> void: gui_outline_icon.has_outline = false)

func update_with_value(value:int) -> void:
	label.text = str(value)
