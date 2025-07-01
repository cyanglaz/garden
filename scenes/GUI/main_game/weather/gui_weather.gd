class_name GUIWeather
extends PanelContainer

@onready var _texture_rect: TextureRect = %TextureRect

func setup_with_weather_data(weather_data:WeatherData) -> void:
	_texture_rect.texture = load(Util.get_icon_image_path_for_weather_id(weather_data.id))
