class_name GUIChestRewardTrinket
extends PanelContainer

signal trinket_selected()

const ICON_PREFIX := "res://resources/sprites/GUI/icons/trinkets/icon_%s.png"

@onready var gui_icon: GUIIcon = %GUIIcon
@onready var name_label: Label = %NameLabel

var mouse_disabled: bool = false: set = _set_mouse_disabled

var _trinket_data: TrinketData = null
var _tooltip_id: String = ""

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_with_trinket_data(trinket_data: TrinketData) -> void:
	_trinket_data = trinket_data
	gui_icon.texture = load(ICON_PREFIX % trinket_data.id)
	name_label.text = trinket_data.display_name

func _gui_input(event: InputEvent) -> void:
	if mouse_disabled:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		trinket_selected.emit()

func _on_mouse_entered() -> void:
	if _trinket_data == null:
		return
	gui_icon.has_outline = true
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(
		TooltipRequest.TooltipType.THING_DATA,
		_trinket_data,
		_tooltip_id,
		self,
		GUITooltip.TooltipPosition.RIGHT
	))

func _on_mouse_exited() -> void:
	gui_icon.has_outline = false
	if not _tooltip_id.is_empty():
		Events.request_hide_tooltip.emit(_tooltip_id)
		_tooltip_id = ""

func _set_mouse_disabled(val: bool) -> void:
	mouse_disabled = val
	mouse_filter = Control.MOUSE_FILTER_IGNORE if val else Control.MOUSE_FILTER_STOP
