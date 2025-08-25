class_name GUIWeatherTooltip
extends GUITooltip

@onready var _name_label: Label = %NameLabel
@onready var _gui_action_list: GUIActionList = %GUIActionList
@onready var _rich_text_label: RichTextLabel = %RichTextLabel

func update_with_weather_data(weather_data:WeatherData) -> void:
	_name_label.text = weather_data.display_name
	if weather_data.actions.is_empty():
		_rich_text_label.text = weather_data.get_display_description()
	else:
		_gui_action_list.update(weather_data.actions)
