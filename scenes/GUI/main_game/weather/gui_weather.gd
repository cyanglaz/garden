class_name GUIWeather
extends PanelContainer

@onready var _texture_rect: TextureRect = %TextureRect

var _weak_weather_tooltip:WeakRef = weakref(null)
var _weak_weather_data:WeakRef

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup_with_weather_data(weather_data:WeatherData) -> void:
	_weak_weather_data = weakref(weather_data)
	_texture_rect.texture = load(Util.get_icon_image_path_for_weather_id(weather_data.id))

func _on_mouse_entered() -> void:
	_weak_weather_tooltip = weakref(Util.display_weather_tooltip(_weak_weather_data.get_ref(), self, false, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited() -> void:
	if _weak_weather_tooltip.get_ref():
		_weak_weather_tooltip.get_ref().queue_free()
		_weak_weather_tooltip = weakref(null)
