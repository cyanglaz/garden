class_name GUIRewardHP
extends PanelContainer

@onready var label: Label = %Label

func update_with_value(val:int) -> void:
	label.text = str(val)
