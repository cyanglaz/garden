class_name GUIEnchantShopPanel
extends GUIShopPanel

@onready var gui_enchant_icon: GUIEnchantIcon = %GUIEnchantIcon

var _weak_enchant_data: WeakRef = weakref(null)
var _enchant_tooltip_id: String = ""

func update_with_enchant_data(enchant_data: EnchantData) -> void:
	_weak_enchant_data = weakref(enchant_data)
	gui_enchant_icon.update_with_enchant_data(enchant_data, null)
	gui_enchant_icon.mouse_interaction_enabled = false
	gui_enchant_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cost = enchant_data.cost

func get_enchant_data() -> EnchantData:
	return _weak_enchant_data.get_ref()

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	if !_enchant_tooltip_id.is_empty():
		return
	_enchant_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(
		TooltipRequest.new(TooltipRequest.TooltipType.ENCHANT, _weak_enchant_data.get_ref(), _enchant_tooltip_id, self, GUITooltip.TooltipPosition.RIGHT)
	)

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	Events.request_hide_tooltip.emit(_enchant_tooltip_id)
	_enchant_tooltip_id = ""
