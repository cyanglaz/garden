class_name WeatherAbilityIcon
extends Node2D

const LEVEL_PREFIX := "Lv.%s"

const ICON_PREFIX := "res://resources/sprites/GUI/icons/weather_ability/icon_%s.png"
const ACTION_LIST_SCENE := preload("res://scenes/GUI/shared/descriptions/shared_description/gui_action_list.tscn")

@onready var gui_icon: GUIIcon = %GUIIcon
@onready var left_action_container: PanelContainer = %LeftActionContainer
@onready var right_action_container: PanelContainer = %RightActionContainer
@onready var level_label: Label = $LevelLabel

var tooltip_position:GUITooltip.TooltipPosition
var _weather_ability_data:WeatherAbilityData
var _action_datas:Array[ActionData]
var _player_action_datas:Array[ActionData]
var _field_action_datas:Array[ActionData]
var _left_action_list:GUIActionList = null
var _right_action_list:GUIActionList = null
var _center_tooltip_id:String = ""
var _left_tooltip_id:String = ""
var _right_tooltip_id:String = ""

func _ready() -> void:
	gui_icon.mouse_entered.connect(_on_center_entered)
	gui_icon.mouse_exited.connect(_on_center_exited)
	left_action_container.mouse_entered.connect(_on_left_entered)
	left_action_container.mouse_exited.connect(_on_left_exited)
	right_action_container.mouse_entered.connect(_on_right_entered)
	right_action_container.mouse_exited.connect(_on_right_exited)

func setup_with_weather_ability_data(data:WeatherAbilityData, level:int) -> void:
	_weather_ability_data = data
	if level > 0:
		level_label.text = str(LEVEL_PREFIX%(level + 1))
	gui_icon.texture = load(ICON_PREFIX % _weather_ability_data.id)
	for action_data in _weather_ability_data.action_datas:
		var leveled_action_data:ActionData = action_data.get_duplicate()
		leveled_action_data.value += level
		_action_datas.append(leveled_action_data)
	_player_action_datas = _action_datas.filter(func(a:ActionData): return a.action_category == ActionData.ActionCategory.PLAYER)
	_field_action_datas = _action_datas.filter(func(a:ActionData): return a.action_category == ActionData.ActionCategory.FIELD)
	if not _player_action_datas.is_empty():
		_left_action_list = ACTION_LIST_SCENE.instantiate()
		_left_action_list.action_alignment = GUIGeneralAction.ActionAlignment.RIGHT
		left_action_container.add_child(_left_action_list)
		_left_action_list.update(_player_action_datas, null)
		left_action_container.show()
	if not _field_action_datas.is_empty():
		_right_action_list = ACTION_LIST_SCENE.instantiate()
		_right_action_list.action_alignment = GUIGeneralAction.ActionAlignment.LEFT
		right_action_container.add_child(_right_action_list)
		_right_action_list.update(_field_action_datas, null)
		right_action_container.show()


func _on_center_entered() -> void:
	gui_icon.is_highlighted = true
	gui_icon.has_outline = true
	_center_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(
		TooltipRequest.TooltipType.WEATHER_ABILITY,
		_weather_ability_data,
		_center_tooltip_id,
		gui_icon,
		tooltip_position,
		{"action_datas": _action_datas}
	))

func _on_center_exited() -> void:
	gui_icon.is_highlighted = false
	gui_icon.has_outline = false
	Events.request_hide_tooltip.emit(_center_tooltip_id)

func _on_left_entered() -> void:
	if _left_action_list == null:
		return
	_left_action_list.set_highlighted(true)
	_left_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(
		TooltipRequest.TooltipType.ACTIONS,
		_player_action_datas,
		_left_tooltip_id,
		left_action_container,
		GUITooltip.TooltipPosition.LEFT,
		{"title": Util.get_localized_string("WEATHER_ABILITY_TO_PLAYER_NAME")}
	))

func _on_left_exited() -> void:
	if _left_action_list:
		_left_action_list.set_highlighted(false)
	Events.request_hide_tooltip.emit(_left_tooltip_id)

func _on_right_entered() -> void:
	if _right_action_list == null:
		return
	_right_action_list.set_highlighted(true)
	_right_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(
		TooltipRequest.TooltipType.ACTIONS,
		_field_action_datas,
		_right_tooltip_id,
		right_action_container,
		GUITooltip.TooltipPosition.RIGHT,
		{"title": Util.get_localized_string("WEATHER_ABILITY_TO_PLANT_NAME")}
	))

func _on_right_exited() -> void:
	if _right_action_list:
		_right_action_list.set_highlighted(false)
	Events.request_hide_tooltip.emit(_right_tooltip_id)
