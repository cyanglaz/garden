class_name GUIWeatherTooltip
extends GUITooltip

@onready var _gui_generic_description: GUIGenericDescription = %GUIGenericDescription

func update_with_weather_data(weather_data:WeatherData) -> void:
	_gui_generic_description.update(weather_data.display_name, weather_data.actions, weather_data.get_display_description())
