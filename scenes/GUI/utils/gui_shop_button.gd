class_name GUIShopButton
extends GUIBasicButton

const TEXTURE_SIZE := 16

@onready var gui_shop_cost_panel: GUIShopCostPanel = %GUIShopCostPanel
@onready var background: NinePatchRect = %Background
@onready var sold_texture: TextureRect = %SoldTexture
@onready var margin_container: MarginContainer = %MarginContainer

var cost:int:set = _set_cost
var sufficient_gold := false: set = _set_sufficient_gold
var sold_out := false : set = _set_sold_out

func _ready() -> void:
	super._ready()
	sold_texture.visible = false
	set_deferred("custom_minimum_size", size) # Shop button size should not changing after hiding content

func update_for_gold(gold:int) -> void:
	sufficient_gold = cost <= gold

func _validate_for_sold_out() -> void:
	if sold_out:
		sold_texture.visible = sold_out
		for child in margin_container.get_children():
			if child != sold_texture:
				child.hide()
		if button_state != GUIBasicButton.ButtonState.DISABLED:
			button_state = GUIBasicButton.ButtonState.DISABLED
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _set_cost(val:int) -> void:
	cost = val
	gui_shop_cost_panel.update_with_cost(cost)
	_validate_for_sold_out()

func _set_sufficient_gold(val:bool) -> void:
	sufficient_gold = val
	gui_shop_cost_panel.sufficient_gold = val
	if val:
		button_state = ButtonState.NORMAL
	else:
		button_state = ButtonState.DISABLED
	_validate_for_sold_out()

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

func _set_sold_out(val:bool) -> void:
	sold_out = val
	_validate_for_sold_out()
