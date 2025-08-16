class_name GUIPoints
extends HBoxContainer

@onready var earned_label: Label = %EarnedLabel
@onready var due_amount_label: Label = %DueAmountLabel

func update_earned(points:int) -> void:
	earned_label.text = str(points)

func update_due(points:int) -> void:
	due_amount_label.text = str(points)
