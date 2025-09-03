class_name GUILevelTooltip
extends GUITooltip

const PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")
const WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")

@onready var name_label: Label = %NameLabel
@onready var max_day_label: Label = %MaxDayLabel
@onready var plants_container: HBoxContainer = %PlantsContainer
@onready var weathers_container: HBoxContainer = %WeathersContainer
@onready var check: TextureRect = %Check

var _weak_plant_tooltip:WeakRef = weakref(null)
var _weak_weather_tooltip:WeakRef = weakref(null)
var _weak_weather_action_tooltip:WeakRef = weakref(null)

func update_with_level(level_data:LevelData) -> void:
	if level_data.display_name.is_empty():
		name_label.hide()
	else:
		name_label.show()
		name_label.text = level_data.display_name
	max_day_label.text = Util.get_localized_string("MAX_DAY_LABEL_TEXT") % level_data.number_of_days
	Util.remove_all_children(plants_container)
	Util.remove_all_children(weathers_container)
	for plant_data:PlantData in level_data.plants:
		var gui_plant_icon: GUIPlantIcon = PLANT_ICON_SCENE.instantiate()
		plants_container.add_child(gui_plant_icon)
		gui_plant_icon.update_with_plant_data(plant_data)
		gui_plant_icon.mouse_entered.connect(_on_mouse_entered_plant_icon.bind(plant_data))
		gui_plant_icon.mouse_exited.connect(_on_mouse_exited_plant_icon)
	for weather_data:WeatherData in level_data.weathers:
		var gui_weather: GUIWeather = WEATHER_SCENE.instantiate()
		weathers_container.add_child(gui_weather)
		gui_weather.setup_with_weather_data(weather_data)
		gui_weather.has_tooltip = true
		gui_weather.tooltip_anchor = self
		gui_weather.weather_tooltip_shown.connect(_on_weather_tooltip_shown)
		gui_weather.weather_action_tooltip_shown.connect(_on_weather_action_tooltip_shown)
		gui_weather.tooltips_removed.connect(_on_tooltips_removed)
	check.visible = level_data.is_finished

func _on_mouse_entered_plant_icon(plant_data:PlantData) -> void:
	_weak_plant_tooltip = weakref(Util.display_plant_tooltip(plant_data, self, false, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited_plant_icon() -> void:
	if _weak_plant_tooltip.get_ref():
		_weak_plant_tooltip.get_ref().queue_free()
		_weak_plant_tooltip = weakref(null)

func queue_destroy_with_tooltips() -> void:
	if _weak_plant_tooltip.get_ref():
		_weak_plant_tooltip.get_ref().queue_free()
		_weak_plant_tooltip = weakref(null)
	if _weak_weather_tooltip.get_ref():
		_weak_weather_tooltip.get_ref().queue_free()
		_weak_weather_tooltip = weakref(null)
	if _weak_weather_action_tooltip.get_ref():
		_weak_weather_action_tooltip.get_ref().queue_free()
		_weak_weather_action_tooltip = weakref(null)
	queue_free()

func _on_weather_tooltip_shown(tooltip:GUIWeatherTooltip) -> void:
	_weak_weather_tooltip = weakref(tooltip)

func _on_weather_action_tooltip_shown(tooltip:GUIActionsTooltip) -> void:
	_weak_weather_action_tooltip = weakref(tooltip)

func _on_tooltips_removed() -> void:
	if _weak_weather_tooltip.get_ref():
		_weak_weather_tooltip.get_ref().queue_free()
		_weak_weather_tooltip = weakref(null)
