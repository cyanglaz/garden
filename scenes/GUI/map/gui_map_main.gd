class_name GUIMapMain
extends CanvasLayer

signal node_button_pressed(node:MapNode)

@onready var gui_map_view: GUIMapView = %GUIMapView
@onready var tooltip_anchor: Control = %TooltipAnchor

var _tooltip_id:String = ""

func _ready() -> void:
	gui_map_view.node_button_pressed.connect(func(node:MapNode) -> void: node_button_pressed.emit(node))
	gui_map_view.node_mouse_entered.connect(_on_node_mouse_entered)
	gui_map_view.node_mouse_exited.connect(_on_node_mouse_exited)

func update_with_map(layers:Array) -> void:
	gui_map_view.update_with_map.call_deferred(layers)

func redraw(layers:Array) -> void:
	gui_map_view.redraw(layers)

func _on_node_mouse_entered(node:MapNode) -> void:
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.MAP, node, _tooltip_id, tooltip_anchor, false, GUITooltip.TooltipPosition.BOTTOM_LEFT, false)

func _on_node_mouse_exited(_node:MapNode) -> void:
	Events.request_hide_tooltip.emit(_tooltip_id)
