class_name GUIWeather
extends PanelContainer

signal tooltips_removed()

@export var has_tooltip:bool = false

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

var is_highlighted:bool = false:set = _set_is_highlighted
var tooltip_anchor:Control
var _tooltip_id:String = ""
var _weak_weather_data:WeakRef

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# For display only, not used for tooltip
func setup_with_weather_id(weather_id:String) -> void:
	_texture_rect.texture = load(Util.get_icon_image_path_for_weather_id(weather_id))

func setup_with_weather_data(weather_data:WeatherData) -> void:
	assert(weather_data != null)
	_weak_weather_data = weakref(weather_data)
	_texture_rect.texture = load(Util.get_icon_image_path_for_weather_id(weather_data.id))

func play_flying_sound() -> void:
	_audio_stream_player_2d.play()

func _on_mouse_entered() -> void:
	if !has_tooltip:
		return
	#if !_weak_weather_data.get_ref():
		#return
	Events.update_hovered_data.emit(_weak_weather_data.get_ref())
	is_highlighted = true
	var anchor = tooltip_anchor if tooltip_anchor else self
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.WEATHER, _weak_weather_data.get_ref(), _tooltip_id, anchor, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited() -> void:
	is_highlighted = false
	Events.update_hovered_data.emit(null)
	Events.request_hide_tooltip.emit(_tooltip_id)
	tooltips_removed.emit()

func _set_is_highlighted(val:bool) -> void:
	is_highlighted = val
	if is_highlighted:
		(_texture_rect.material as ShaderMaterial).set_shader_parameter("blend_strength", 0.2)
	else:
		(_texture_rect.material as ShaderMaterial).set_shader_parameter("blend_strength", 0.0)
