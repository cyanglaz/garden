class_name WeatherAbilityIcon
extends Node2D

const ICON_PREFIX := "res://resources/sprites/GUI/icons/weather_ability/icon_%s.png"

@onready var gui_icon: GUIIcon = %GUIIcon

var _weather_ability_data:WeatherAbilityData
var _tooltip_id:String = ""

func _ready() -> void:
	gui_icon.mouse_entered.connect(_on_mouse_entered)
	gui_icon.mouse_exited.connect(_on_mouse_exited)

func setup_with_weather_ability_data(data:WeatherAbilityData) -> void:
	_weather_ability_data = data
	gui_icon.texture = load(ICON_PREFIX % _weather_ability_data.id)

func _on_mouse_entered() -> void:
	gui_icon.is_highlighted = true
	gui_icon.has_outline = true
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.WEATHER_ABILITY, _weather_ability_data, _tooltip_id, gui_icon, GUITooltip.TooltipPosition.RIGHT))

func _on_mouse_exited() -> void:
	gui_icon.is_highlighted = false
	gui_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)
