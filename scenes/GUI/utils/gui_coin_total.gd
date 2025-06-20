class_name GUICoinTotal
extends HBoxContainer

@onready var label: Label = $Label

var total:int : set = _set_total

func _ready() -> void:
	label.text = str(total)
	Events.currency_updated.connect(_on_currency_updated)

func _set_total(val:int):
	total = val
	if label:
		label.text = str(total)
	
func _on_currency_updated(amount:int):
	total = amount
