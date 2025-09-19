class_name GUIShopButton
extends GUIBasicButton

const SUFFICIENT_GOLD_COLOR := Constants.COLOR_WHITE
const INSUFFICIENT_GOLD_COLOR := Constants.COLOR_GRAY3

@onready var cost_label: Label = %CostLabel
@onready var gui_shop_gold_icon: GUIShopGoldIcon = %GUIShopGoldIcon

var cost:int:set = _set_cost
var sufficient_gold := false: set = _set_sufficient_gold
var highlighted := false: set = _set_highlighted

func update_for_gold(gold:int) -> void:
	sufficient_gold = cost <= gold

func _set_cost(val:int) -> void:
	cost = val
	cost_label.text = str(cost)

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	highlighted = true
	gui_shop_gold_icon.has_outline = true

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	highlighted = false
	gui_shop_gold_icon.has_outline = false

func _set_sufficient_gold(val:bool) -> void:
	sufficient_gold = val
	if val:
		cost_label.add_theme_color_override("font_color", SUFFICIENT_GOLD_COLOR)
	else:
		cost_label.add_theme_color_override("font_color", INSUFFICIENT_GOLD_COLOR)

func _set_highlighted(val:bool) -> void:
	highlighted = val
