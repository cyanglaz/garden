class_name GUIShopButton
extends GUIBasicButton

@onready var cost_label: Label = %CostLabel

var cost:int:set = _set_cost

func update_for_gold(gold:int) -> void:
	if cost > gold:
		button_state = ButtonState.DISABLED
	else:
		button_state = ButtonState.NORMAL

func _set_cost(val:int) -> void:
	cost = val
	cost_label.text = str(cost)
