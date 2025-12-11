class_name GUIWeatherTooltip
extends GUITooltip

const ACTION_TOOLTIP_DELAY := 0.2

@onready var _name_label: Label = %NameLabel
@onready var _gui_action_list: GUIActionList = %GUIActionList
@onready var _rich_text_label: RichTextLabel = %RichTextLabel

var display_mode := false
var _tooltip_id:String = ""

func _ready() -> void:
	super._ready()
	tool_tip_shown.connect(_on_tooltop_shown)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _update_with_tooltip_request() -> void:
	var weather_data:WeatherData = _tooltip_request.data as WeatherData
	_name_label.text = weather_data.get_display_name()
	if weather_data.actions.is_empty():
		_rich_text_label.text = weather_data.get_display_description()
	else:
		_gui_action_list.update(weather_data.actions, null)

func _on_tooltop_shown() -> void:
	if display_mode:
		return
	await Util.create_scaled_timer(ACTION_TOOLTIP_DELAY).timeout
	_show_actions_tooltip()

func _on_mouse_entered() -> void:
	if display_mode:
		_show_actions_tooltip()

func _on_mouse_exited() -> void:
	if display_mode:
		_hide_actions_tooltip()

func _show_actions_tooltip() -> void:
	if (_tooltip_request.data as WeatherData).actions.is_empty():
		return
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.ACTIONS, _tooltip_request.data.actions, _tooltip_id, self, self.tooltip_position))

func _hide_actions_tooltip() -> void:
	Events.request_hide_tooltip.emit(_tooltip_id)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_hide_actions_tooltip()
