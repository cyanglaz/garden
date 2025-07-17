class_name GUIWeatherTooltip
extends GUITooltip

@onready var _name_label: Label = %NameLabel
@onready var _rich_text_label: RichTextLabel = %RichTextLabel

func update_with_weather_data(weather_data:WeatherData) -> void:
	_name_label.text = weather_data.display_name
	_rich_text_label.text = weather_data.get_display_description()
