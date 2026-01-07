class_name WeatherAbilityIcon
extends Node2D

const ICON_PREFIX := "res://resources/sprites/GUI/icons/weather_ability/icon_%s.png"
const GUI_GENERAL_ACTION_SCENE := preload("res://scenes/GUI/main_game/actions/gui_general_action.tscn")


@onready var gui_icon: GUIIcon = %GUIIcon
@onready var to_plants_container: VBoxContainer = %ToPlantsContainer

var _weather_ability_data:WeatherAbilityData
var _tooltip_id:String = ""

func _ready() -> void:
	gui_icon.mouse_entered.connect(_on_mouse_entered)
	gui_icon.mouse_exited.connect(_on_mouse_exited)

func setup_with_weather_ability_data(data:WeatherAbilityData) -> void:
	_weather_ability_data = data
	gui_icon.texture = load(ICON_PREFIX % _weather_ability_data.id)
	Util.remove_all_children(to_plants_container)
	for action_data:ActionData in data.plant_actions:
		if action_data.value_type == ActionData.ValueType.X:
			var action_scene_x:GUIGeneralAction = GUI_GENERAL_ACTION_SCENE.instantiate()
			to_plants_container.add_child(action_scene_x)
			action_scene_x.update_for_x(action_data.get_calculated_x_value(null), action_data.x_value_type)
		var action_scene:GUIGeneralAction = GUI_GENERAL_ACTION_SCENE.instantiate()
		to_plants_container.add_child(action_scene)
		action_scene.update_with_action(action_data, null)

func _on_mouse_entered() -> void:
	gui_icon.is_highlighted = true
	gui_icon.has_outline = true
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.WEATHER_ABILITY, _weather_ability_data, _tooltip_id, gui_icon, GUITooltip.TooltipPosition.RIGHT))

func _on_mouse_exited() -> void:
	gui_icon.is_highlighted = false
	gui_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)
