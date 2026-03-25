class_name GUIRewardGold
extends GUIBasicButton

signal gold_collected()

@onready var gui_icon: GUIIcon = %GUIIcon
@onready var label: Label = %Label

func _ready() -> void:
	super._ready()
	pressed.connect(func(): gold_collected.emit())

func update_with_value(val: int) -> void:
	label.text = str(val)

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	gui_icon.has_outline = true

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	gui_icon.has_outline = false
