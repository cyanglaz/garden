class_name GUIShopCostPanel
extends PanelContainer

const SUFFICIENT_GOLD_COLOR := Constants.COLOR_BROWN_1
const INSUFFICIENT_GOLD_COLOR := Constants.COLOR_GRAY3

@onready var cost_label: Label = %CostLabel

var sufficient_gold := false: set = _set_sufficient_gold

func update_with_cost(cost:int) -> void:
	cost_label.text = str(cost)	

func _set_sufficient_gold(val:bool) -> void:
	sufficient_gold = val
	if val:
		cost_label.add_theme_color_override("font_color", SUFFICIENT_GOLD_COLOR)
	else:
		cost_label.add_theme_color_override("font_color", INSUFFICIENT_GOLD_COLOR)
