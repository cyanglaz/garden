class_name GUIShopButton
extends GUIBasicButton

const TEXTURE_SIZE := 16

@onready var gui_shop_cost_panel: GUIShopCostPanel = %GUIShopCostPanel
@onready var background: NinePatchRect = %Background

var cost:int:set = _set_cost
var sufficient_gold := false: set = _set_sufficient_gold

func _ready() -> void:
	super._ready()

func update_for_gold(gold:int) -> void:
	sufficient_gold = cost <= gold

func _set_cost(val:int) -> void:
	cost = val
	gui_shop_cost_panel.update_with_cost(cost)

func _set_sufficient_gold(val:bool) -> void:
	sufficient_gold = val
	gui_shop_cost_panel.sufficient_gold = val
	if val:
		button_state = ButtonState.NORMAL
	else:
		button_state = ButtonState.DISABLED

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !background:
		return
	match button_state:
		ButtonState.NORMAL:
			background.region_rect.position = Vector2.ZERO
		ButtonState.PRESSED:
			background.region_rect.position = Vector2(TEXTURE_SIZE, 0)
		ButtonState.HOVERED:
			background.region_rect.position = Vector2(TEXTURE_SIZE*2, 0)
		ButtonState.DISABLED:
			background.region_rect.position = Vector2(0, TEXTURE_SIZE)
		ButtonState.SELECTED:
			background.region_rect.position = Vector2(TEXTURE_SIZE, TEXTURE_SIZE)			
