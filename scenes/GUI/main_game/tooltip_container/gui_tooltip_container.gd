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
const GUI_MAP_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_map_tooltip.tscn")
const GUI_REFERENCE_CARD_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_reference_card_tooltip.tscn")
const GUI_PLANT_ABILITY_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_ability_tooltip.tscn")

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

func _on_request_display_tooltip(tooltip_request:TooltipRequest) -> void:
	var gui_tooltip:GUITooltip = _create_tooltip(tooltip_request.tooltip_type)
	gui_tooltip.update_with_request(tooltip_request)
	add_child(gui_tooltip)
	var anchor_node:Control = tooltip_request.on_control_node
	if _tooltips.has(tooltip_request.id):
		anchor_node = (_tooltips[tooltip_request.id] as Array).back()
	var is_world_space:bool = _is_anchor_world_space(anchor_node)
	_display_tool_tip(gui_tooltip, anchor_node, tooltip_request.anchor_mouse, is_world_space)
	if !_tooltips.has(tooltip_request.id):
		_tooltips[tooltip_request.id] = []
	_tooltips[tooltip_request.id].append(gui_tooltip)

func _create_tooltip(tooltip_type:TooltipRequest.TooltipType) -> GUITooltip:
	match tooltip_type:
		TooltipRequest.TooltipType.BUTTON:
			return GUI_BUTTON_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.WARNING:
			return GUI_WARNING_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.RICH_TEXT:
			return GUI_RICH_TEXT_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.PLANT:
			return GUI_PLANT_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.WEATHER:
			return GUI_WEATHER_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.THING_DATA:
			return GUI_THING_DATA_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.ACTIONS:
			return GUI_ACTIONS_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.VIEW_DETAIL:
			return GUI_SHOW_DETAIL_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.BOSS:
			return GUI_BOSS_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.BOOSTER_PACK:
			return GUI_BOOSTER_PACK_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.TOOL_CARD:
			return GUI_TOOL_CARD_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.SPECIALS:
			return GUI_SPECIALS_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.MAP:
			return GUI_MAP_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.REFERENCE_CARD:
			return GUI_REFERENCE_CARD_TOOLTIP_SCENE.instantiate()
		TooltipRequest.TooltipType.PLANT_ABILITY:
			return GUI_PLANT_ABILITY_TOOLTIP_SCENE.instantiate()
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

func _is_anchor_world_space(control:Control) -> bool:
	var parent:Variant = control
	while parent != get_tree().root:
		if parent is CanvasLayer:
			return false
		parent = parent.get_parent()
	return true
