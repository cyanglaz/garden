class_name GUIRewardGold
extends HBoxContainer

@onready var label: Label = %Label

func update_with_value(val:int) -> void:
	label.text = str(val)
