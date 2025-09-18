class_name GUIWeather
extends PanelContainer

signal weather_tooltip_shown(tooltip:GUIWeatherTooltip)
signal tooltips_removed()

@export var has_tooltip:bool = false

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

var is_highlighted:bool = false:set = _set_is_highlighted
var tooltip_anchor:Control
var _weak_weather_tooltip:WeakRef = weakref(null)
var _weak_weather_data:WeakRef

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
	is_highlighted = true
	var anchor = tooltip_anchor if tooltip_anchor else self
	_weak_weather_tooltip = weakref(Util.display_weather_tooltip(_weak_weather_data.get_ref(), anchor, false, GUITooltip.TooltipPosition.LEFT))
	weather_tooltip_shown.emit(_weak_weather_tooltip.get_ref())

func _on_mouse_exited() -> void:
	is_highlighted = false
	if _weak_weather_tooltip.get_ref():
		_weak_weather_tooltip.get_ref().queue_free()
		_weak_weather_tooltip = weakref(null)
	tooltips_removed.emit()

func _set_is_highlighted(val:bool) -> void:
	is_highlighted = val
	if is_highlighted:
		(_texture_rect.material as ShaderMaterial).set_shader_parameter("blend_strength", 0.2)
	else:
		(_texture_rect.material as ShaderMaterial).set_shader_parameter("blend_strength", 0.0)
