class_name GUITooltipContainer
extends Control

const TOOLTIP_OFFSET:float = 2.0

const GUI_BUTTON_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_button_tooltip.tscn")
const GUI_PLANT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")
const GUI_WEATHER_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_weather_tooltip.tscn")
const GUI_THING_DATA_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_thing_data_tooltip.tscn")
const GUI_ACTIONS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_actions_tooltip.tscn")
const GUI_SPECIALS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_specials_tooltip.tscn")
const GUI_WARNING_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_warning_tooltip.tscn")
const GUI_RICH_TEXT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_rich_text_tooltip.tscn")
const GUI_TOOL_CARD_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_tool_card_tooltip.tscn")
const GUI_SHOW_DETAIL_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_show_detail_tooltip.tscn")
const GUI_BOOSTER_PACK_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_booster_pack_tooltip.tscn")
const GUI_BOSS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_boss_tooltip.tscn")
const GUI_CONTRACT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_contract_tooltip.tscn")
const GUI_MAP_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_map_tooltip.tscn")
const GUI_REFERENCE_CARD_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_reference_card_tooltip.tscn")

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
	CONTRACT,
	TOOL_CARD,
	SPECIALS,
	MAP,
	REFERENCE_CARD,
}

var _tooltips:Dictionary = {}

func _ready() -> void:
	Events.request_display_tooltip.connect(_on_request_display_tooltip)
	Events.request_hide_tooltip.connect(_on_request_hide_tooltip)

func clear_all_tooltips() -> void:
	for tooltips in _tooltips.values():
		for tooltip in tooltips:
			tooltip.queue_free()
	_tooltips.clear()

func _on_request_hide_tooltip(id:String) -> void:
	if _tooltips.has(id):
		for tooltip in _tooltips[id]:
			tooltip.queue_free()
		_tooltips.erase(id)

func _on_request_display_tooltip(tooltip_type:TooltipType, data:Variant, id:String, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition, world_space:bool) -> void:
	var gui_tooltip:GUITooltip = _create_tooltip(tooltip_type)
	gui_tooltip.update_with_data(data)
	gui_tooltip.tooltip_position = tooltip_position
	add_child(gui_tooltip)
	var anchor_node:Control = on_control_node
	if _tooltips.has(id):
		anchor_node = (_tooltips[id] as Array).back()
	_display_tool_tip(gui_tooltip, anchor_node, anchor_mouse, world_space)
	if !_tooltips.has(id):
		_tooltips[id] = []
	_tooltips[id].append(gui_tooltip)

func _create_tooltip(tooltip_type:TooltipType) -> GUITooltip:
	match tooltip_type:
		TooltipType.BUTTON:
			return GUI_BUTTON_TOOLTIP_SCENE.instantiate()
		TooltipType.WARNING:
			return GUI_WARNING_TOOLTIP_SCENE.instantiate()
		TooltipType.RICH_TEXT:
			return GUI_RICH_TEXT_TOOLTIP_SCENE.instantiate()
		TooltipType.PLANT:
			return GUI_PLANT_TOOLTIP_SCENE.instantiate()
		TooltipType.WEATHER:
			return GUI_WEATHER_TOOLTIP_SCENE.instantiate()
		TooltipType.THING_DATA:
			return GUI_THING_DATA_TOOLTIP_SCENE.instantiate()
		TooltipType.ACTIONS:
			return GUI_ACTIONS_TOOLTIP_SCENE.instantiate()
		TooltipType.VIEW_DETAIL:
			return GUI_SHOW_DETAIL_TOOLTIP_SCENE.instantiate()
		TooltipType.BOSS:
			return GUI_BOSS_TOOLTIP_SCENE.instantiate()
		TooltipType.BOOSTER_PACK:
			return GUI_BOOSTER_PACK_TOOLTIP_SCENE.instantiate()
		TooltipType.CONTRACT:
			return GUI_CONTRACT_TOOLTIP_SCENE.instantiate()
		TooltipType.TOOL_CARD:
			return GUI_TOOL_CARD_TOOLTIP_SCENE.instantiate()
		TooltipType.SPECIALS:
			return GUI_SPECIALS_TOOLTIP_SCENE.instantiate()
		TooltipType.MAP:
			return GUI_MAP_TOOLTIP_SCENE.instantiate()
		TooltipType.REFERENCE_CARD:
			return GUI_REFERENCE_CARD_TOOLTIP_SCENE.instantiate()
		_:
			assert(false, "Invalid tooltip type: %s" % tooltip_type)
			return null

func _display_tool_tip(tooltip:Control, on_control_node:Control, anchor_mouse:bool, world_space:bool = false) -> void:
	tooltip.show()
	if tooltip is GUITooltip:
		tooltip.anchor_to_mouse = anchor_mouse
		tooltip.show_tooltip()
		tooltip.update_anchors()
	if anchor_mouse && on_control_node:
		tooltip.triggering_global_rect = on_control_node.get_global_rect()
		return
	if !on_control_node:
		return
	var y_offset:float = 0
	var x_offset:float = 0
	var real_tooltip_size := tooltip.size * tooltip.scale
	var real_on_control_node_size := on_control_node.size * on_control_node.scale
	match tooltip.tooltip_position:
		GUITooltip.TooltipPosition.TOP_RIGHT:
			x_offset = real_on_control_node_size.x + TOOLTIP_OFFSET
			y_offset = - real_tooltip_size.y + real_on_control_node_size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.TOP:
			x_offset = real_on_control_node_size.x/2 - real_tooltip_size.x/2
			y_offset = - real_tooltip_size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.RIGHT:
			x_offset = real_on_control_node_size.x + TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.LEFT_TOP:
			x_offset = - real_tooltip_size.x - TOOLTIP_OFFSET
			y_offset = - real_tooltip_size.y + real_on_control_node_size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.LEFT:
			x_offset = -real_tooltip_size.x - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.BOTTOM:
			x_offset = real_on_control_node_size.x/2 - real_tooltip_size.x/2
			y_offset = real_on_control_node_size.y + TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.BOTTOM_LEFT:
			x_offset = -real_tooltip_size.x + real_on_control_node_size.x
			y_offset = real_on_control_node_size.y + TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.BOTTOM_RIGHT:
			y_offset = real_on_control_node_size.y + TOOLTIP_OFFSET
	var reference_position := on_control_node.global_position
	if world_space:
		assert(on_control_node)
		reference_position = Util.get_node_canvas_position(on_control_node)
	tooltip.global_position = reference_position + Vector2(x_offset, y_offset)
	tooltip.adjust_positions()
