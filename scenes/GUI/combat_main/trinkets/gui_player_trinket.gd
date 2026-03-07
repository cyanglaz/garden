class_name GUIPlayerTrinket
extends PanelContainer

const ICON_PREFIX := "res://resources/sprites/GUI/icons/trinkets/icon_%s.png"

@onready var gui_icon: GUIIcon = %GUIIcon
@onready var stack: Label = %Stack

var _tooltip_id:String = ""
var _trinket_data:TrinketData = null

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_with_trinket_data(trinket_data:TrinketData) -> void:
	_trinket_data = trinket_data
	gui_icon.texture = load(ICON_PREFIX % trinket_data.id)
	if trinket_data.stack > 0:
		stack.text = str(trinket_data.stack)
	else:
		stack.text = ""

func _on_mouse_entered() -> void:
	gui_icon.has_outline = true
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.THING_DATA, _trinket_data, _tooltip_id, self, GUITooltip.TooltipPosition.TOP_RIGHT))

func _on_mouse_exited() -> void:
	gui_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)
