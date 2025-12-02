class_name TooltipRequest
extends RefCounted

enum TooltipType {
	BUTTON,
	WARNING,
	RICH_TEXT,
	PLANT,
	WEATHER,
	THING_DATA,
	ACTIONS,
	VIEW_DETAIL,
	BOSS,
	BOOSTER_PACK,
	COMBAT,
	TOOL_CARD,
	SPECIALS,
	MAP,
	REFERENCE_CARD,
	PLANT_ABILITY,
}

var tooltip_type:TooltipType
var data:Variant
var id:String
var on_control_node:Control: set = _set_on_control_node, get = _get_on_control_node
var tooltip_position: GUITooltip.TooltipPosition
var additional_data:Dictionary = {}
var anchor_mouse:bool = false

var _weak_on_control_node:WeakRef = weakref(null)

func _init(param_tooltip_type:TooltipType, param_data:Variant, param_id:String, param_on_control_node:Control, param_tooltip_position: GUITooltip.TooltipPosition, param_additional_data:Dictionary = {}, param_anchor_mouse:bool = false) -> void:
	tooltip_type = param_tooltip_type
	data = param_data
	id = param_id
	on_control_node = param_on_control_node
	tooltip_position = param_tooltip_position
	additional_data = param_additional_data
	anchor_mouse = param_anchor_mouse

func _set_on_control_node(val:Control) -> void:
	_weak_on_control_node = weakref(val)

func _get_on_control_node() -> Control:
	return _weak_on_control_node.get_ref()
