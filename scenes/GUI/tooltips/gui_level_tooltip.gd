class_name GUILevelTooltip
extends GUITooltip

const PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")
const WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")

@onready var max_day_label: Label = %MaxDayLabel
@onready var plants_container: HBoxContainer = %PlantsContainer
@onready var weathers_container: HBoxContainer = %WeathersContainer
@onready var check: TextureRect = %Check

var _weak_plant_tooltip:WeakRef = weakref(null)
var _weak_weather_tooltip:WeakRef = weakref(null)
var _weak_boss_tooltip:WeakRef = weakref(null)
var _weak_level_data:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	tool_tip_shown.connect(_on_tool_tip_shown)

func update_with_level(level_data:LevelData) -> void:
	_weak_level_data = weakref(level_data)
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
	if _weak_boss_tooltip.get_ref():
		_weak_boss_tooltip.get_ref().queue_free()
		_weak_boss_tooltip = weakref(null)
	queue_free()

func _on_weather_tooltip_shown(tooltip:GUIWeatherTooltip) -> void:
	_weak_weather_tooltip = weakref(tooltip)

func _on_tool_tip_shown() -> void:
	if _weak_level_data.get_ref().type == LevelData.Type.BOSS:
		_weak_boss_tooltip = weakref(Util.display_boss_tooltip(_weak_level_data.get_ref(), self, false, self.tooltip_position))

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _weak_boss_tooltip.get_ref():
			_weak_boss_tooltip.get_ref().queue_free()
			_weak_boss_tooltip = weakref(null)
