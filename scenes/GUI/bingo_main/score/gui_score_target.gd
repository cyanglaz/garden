class_name GUIScoreTarget
extends HBoxContainer

@onready var label: Label = %Label

var score:int: set = _set_score

func _set_score(val:int) -> void:
	score = val
	label.text = str(val)
