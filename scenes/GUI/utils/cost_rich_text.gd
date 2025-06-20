class_name CostRichText
extends RichTextLabel

const COIN_STRING = "[img=8x8]res://resources/sprites/loots/coin_icon.png[/img]"

@export var cost:int: set = _set_cost

func _ready() -> void:
	_set_cost(cost)

func _set_cost(val:int):
	cost = val
	text = str(COIN_STRING," ", cost)
