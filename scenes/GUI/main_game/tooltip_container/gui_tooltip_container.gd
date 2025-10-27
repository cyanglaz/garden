class_name GUITooltipContainer
extends Control

const TOOLTIP_OFFSET:float = 2.0

const GUI_BUTTON_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_button_tooltip.tscn")
const GUI_PLANT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")
const GUI_WEATHER_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_weather_tooltip.tscn")
const GUI_THING_DATA_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_thing_data_tooltip.tscn")
const GUI_ACTIONS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_actions_tooltip.tscn")
const GUI_WARNING_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_warning_tooltip.tscn")
const GUI_RICH_TEXT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_rich_text_tooltip.tscn")
const GUI_TOOL_CARD_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_tool_card_tooltip.tscn")
const GUI_SHOW_DETAIL_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_show_detail_tooltip.tscn")
const GUI_BOOSTER_PACK_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_booster_pack_tooltip.tscn")
const GUI_BOSS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_boss_tooltip.tscn")
const GUI_CONTRACT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_contract_tooltip.tscn")

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
}

var _tooltips:Dictionary = {}

func _ready() -> void:
	Events.request_display_tooltip.connect(_on_request_display_tooltip)
	Events.request_hide_tooltip.connect(_on_request_hide_tooltip)

func clear_all_tooltips() -> void:
	for tooltip in _tooltips.values():
		tooltip.queue_free()
	_tooltips.clear()

func _on_request_hide_tooltip(id:String) -> void:
	if _tooltips.has(id):
		_tooltips[id].queue_free()
		_tooltips.erase(id)

func _on_request_display_tooltip(tooltip_type:TooltipType, data:Variant, id:String, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition, world_space:bool) -> void:
	var gui_tooltip:GUITooltip
	match tooltip_type:
		TooltipType.BUTTON:
			gui_tooltip = GUI_BUTTON_TOOLTIP_SCENE.instantiate()
		TooltipType.WARNING:
			gui_tooltip = GUI_WARNING_TOOLTIP_SCENE.instantiate()
		TooltipType.RICH_TEXT:
			gui_tooltip = GUI_RICH_TEXT_TOOLTIP_SCENE.instantiate()
		TooltipType.PLANT:
			gui_tooltip = GUI_PLANT_TOOLTIP_SCENE.instantiate()
		TooltipType.WEATHER:
			gui_tooltip = GUI_WEATHER_TOOLTIP_SCENE.instantiate()
		TooltipType.THING_DATA:
			gui_tooltip = GUI_THING_DATA_TOOLTIP_SCENE.instantiate()
		TooltipType.ACTIONS:
			gui_tooltip = GUI_ACTIONS_TOOLTIP_SCENE.instantiate()
		TooltipType.VIEW_DETAIL:
			gui_tooltip = GUI_SHOW_DETAIL_TOOLTIP_SCENE.instantiate()
		TooltipType.BOSS:
			gui_tooltip = GUI_BOSS_TOOLTIP_SCENE.instantiate()
		TooltipType.BOOSTER_PACK:
			gui_tooltip = GUI_BOOSTER_PACK_TOOLTIP_SCENE.instantiate()
		TooltipType.CONTRACT:
			gui_tooltip = GUI_CONTRACT_TOOLTIP_SCENE.instantiate()
		TooltipType.TOOL_CARD:
			gui_tooltip = GUI_TOOL_CARD_TOOLTIP_SCENE.instantiate()
		_:
			assert(false, "Invalid tooltip type: %s" % tooltip_type)
			return
	gui_tooltip.update_with_data(data)
	gui_tooltip.tooltip_position = tooltip_position
	add_child(gui_tooltip)
	_display_tool_tip(gui_tooltip, on_control_node, anchor_mouse, world_space)
	_tooltips[id] = gui_tooltip

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
	match tooltip.tooltip_position:
		GUITooltip.TooltipPosition.TOP_RIGHT:
			x_offset = on_control_node.size.x + TOOLTIP_OFFSET
			y_offset = - tooltip.size.y + on_control_node.size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.TOP:
			x_offset = on_control_node.size.x/2 - tooltip.size.x/2
			y_offset = - tooltip.size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.RIGHT:
			x_offset = on_control_node.size.x + TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.LEFT_TOP:
			x_offset = -tooltip.size.x - TOOLTIP_OFFSET
			y_offset = - tooltip.size.y + on_control_node.size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.LEFT:
			x_offset = -tooltip.size.x - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.BOTTOM:
			x_offset = on_control_node.size.x/2 - tooltip.size.x/2
			y_offset = on_control_node.size.y + TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.BOTTOM_LEFT:
			x_offset = -tooltip.size.x + on_control_node.size.x
			y_offset = on_control_node.size.y + TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.BOTTOM_RIGHT:
			y_offset = on_control_node.size.y + TOOLTIP_OFFSET
	var reference_position := on_control_node.global_position
	if world_space:
		assert(on_control_node)
		reference_position = Util.get_node_canvas_position(on_control_node)
	tooltip.global_position = reference_position + Vector2(x_offset, y_offset)
	tooltip.adjust_positions()
