class_name GUIWeather
extends PanelContainer

const ACTION_TOOLTIP_DELAY := 0.2

signal weather_tooltip_shown(tooltip:GUIWeatherTooltip)
signal weather_action_tooltip_shown(tooltip:GUIActionsTooltip)
signal tooltips_removed()

@export var has_tooltip:bool = false

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

var tooltip_anchor:Control
var _weak_weather_tooltip:WeakRef = weakref(null)
var _weak_weather_data:WeakRef
var _weak_actions_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# For display only, not used for tooltip
func setup_with_weather_id(weather_id:String) -> void:
	_texture_rect.texture = load(Util.get_icon_image_path_for_weather_id(weather_id))

func setup_with_weather_data(weather_data:WeatherData) -> void:
	_weak_weather_data = weakref(weather_data)
	_texture_rect.texture = load(Util.get_icon_image_path_for_weather_id(weather_data.id))

func play_flying_sound() -> void:
	_audio_stream_player_2d.play()

func _on_mouse_entered() -> void:
	if !has_tooltip:
		return
	var anchor = tooltip_anchor if tooltip_anchor else self
	_weak_weather_tooltip = weakref(Util.display_weather_tooltip(_weak_weather_data.get_ref(), anchor, false, GUITooltip.TooltipPosition.LEFT))
	weather_tooltip_shown.emit(_weak_weather_tooltip.get_ref())
	await Util.create_scaled_timer(ACTION_TOOLTIP_DELAY).timeout
	if _weak_weather_tooltip.get_ref():
		if _weak_actions_tooltip.get_ref():
			return
		_weak_actions_tooltip = weakref(Util.display_actions_tooltip(_weak_weather_data.get_ref().actions, _weak_weather_tooltip.get_ref(), false, GUITooltip.TooltipPosition.LEFT, false))
		weather_action_tooltip_shown.emit(_weak_actions_tooltip.get_ref())

func _on_mouse_exited() -> void:
	if _weak_weather_tooltip.get_ref():
		_weak_weather_tooltip.get_ref().queue_free()
		_weak_weather_tooltip = weakref(null)
	if _weak_actions_tooltip.get_ref():
		_weak_actions_tooltip.get_ref().queue_free()
		_weak_actions_tooltip = weakref(null)
	tooltips_removed.emit()
