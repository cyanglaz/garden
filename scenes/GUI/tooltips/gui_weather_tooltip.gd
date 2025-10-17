class_name GUIWeatherTooltip
extends GUITooltip

const ACTION_TOOLTIP_DELAY := 0.2

@onready var _name_label: Label = %NameLabel
@onready var _gui_action_list: GUIActionList = %GUIActionList
@onready var _rich_text_label: RichTextLabel = %RichTextLabel

var display_mode := false
var _weak_actions_tooltip:WeakRef = weakref(null)
var _weak_weather_data:WeakRef = weakref(null)

func _ready() -> void:
	tool_tip_shown.connect(_on_tooltop_shown)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_with_weather_data(weather_data:WeatherData) -> void:
	_weak_weather_data = weakref(weather_data)
	_name_label.text = weather_data.display_name
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
	if _weak_weather_data.get_ref().actions.is_empty():
		return
	_weak_actions_tooltip = weakref(Util.display_actions_tooltip(_weak_weather_data.get_ref().actions, null, self, false, self.tooltip_position, false))

func _hide_actions_tooltip() -> void:
	if _weak_actions_tooltip.get_ref():
		_weak_actions_tooltip.get_ref().queue_free()
		_weak_actions_tooltip = weakref(null)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_hide_actions_tooltip()
