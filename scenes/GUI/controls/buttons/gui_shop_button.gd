class_name GUIShopButton
extends GUIBasicButton

const TEXTURE_SIZE := 16

const SUFFICIENT_GOLD_COLOR := Constants.COLOR_ORANGE3
const INSUFFICIENT_GOLD_COLOR := Constants.COLOR_GRAY3

@onready var _background: NinePatchRect = %Background
@onready var cost_label: Label = %CostLabel

var sufficient_gold := false: set = _set_sufficient_gold

func update_with_cost(cost:int) -> void:
	cost_label.text = str(cost)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_background:
		return
	match button_state:
		ButtonState.NORMAL:
			_background.region_rect.position = Vector2.ZERO
		ButtonState.PRESSED:
			_background.region_rect.position = Vector2(TEXTURE_SIZE, 0)
		ButtonState.HOVERED:
			_background.region_rect.position = Vector2(TEXTURE_SIZE*2, 0)
		ButtonState.DISABLED:
			_background.region_rect.position = Vector2(0, TEXTURE_SIZE)
		ButtonState.SELECTED:
			_background.region_rect.position = Vector2(TEXTURE_SIZE, TEXTURE_SIZE)			


func _set_sufficient_gold(val:bool) -> void:
	sufficient_gold = val
	if val:
		cost_label.add_theme_color_override("font_color", SUFFICIENT_GOLD_COLOR)
		button_state = ButtonState.NORMAL
	else:
		cost_label.add_theme_color_override("font_color", INSUFFICIENT_GOLD_COLOR)
		button_state = ButtonState.DISABLED
