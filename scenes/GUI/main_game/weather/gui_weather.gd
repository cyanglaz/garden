class_name GUIWeather
extends PanelContainer

@export var has_tooltip:bool = false

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

var _weak_weather_tooltip:WeakRef = weakref(null)
var _weak_weather_data:WeakRef

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup_with_weather_data(weather_data:WeatherData) -> void:
	_weak_weather_data = weakref(weather_data)
	_texture_rect.texture = load(Util.get_icon_image_path_for_weather_id(weather_data.id))

func play_flying_sound() -> void:
	_audio_stream_player_2d.play()

func _on_mouse_entered() -> void:
	if !has_tooltip:
		return
	_weak_weather_tooltip = weakref(Util.display_weather_tooltip(_weak_weather_data.get_ref(), self, false, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited() -> void:
	if _weak_weather_tooltip.get_ref():
		_weak_weather_tooltip.get_ref().queue_free()
		_weak_weather_tooltip = weakref(null)
