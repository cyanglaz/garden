class_name GUICurrentContractButton
extends GUIBasicButton

@onready var _texture_rect: TextureRect = %TextureRect

var _weak_contract_data:WeakRef = weakref(null)
var _weak_contract_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	pressed.connect(_on_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("select") || event.is_action_released("de-select"):
		if _weak_contract_tooltip.get_ref():
			_weak_contract_tooltip.get_ref().queue_free()
			_weak_contract_tooltip = weakref(null)

func update_with_contract_data(contract_data:ContractData) -> void:
	_weak_contract_data = weakref(contract_data)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_texture_rect:
		return
	match button_state:
		ButtonState.NORMAL:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(0, 0)
		ButtonState.PRESSED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(12, 0)
		ButtonState.HOVERED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(24, 0)
		ButtonState.DISABLED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(0, 12)
		ButtonState.SELECTED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(24, 12)		

func _on_pressed() -> void:
	if _weak_contract_data.get_ref():
		if _weak_contract_tooltip.get_ref():
			_weak_contract_tooltip.get_ref().queue_free()
			_weak_contract_tooltip = weakref(null)
		else:
			_weak_contract_tooltip = weakref(Util.display_contract_tooltip(_weak_contract_data.get_ref(), self, false, GUITooltip.TooltipPosition.BOTTOM_LEFT))
