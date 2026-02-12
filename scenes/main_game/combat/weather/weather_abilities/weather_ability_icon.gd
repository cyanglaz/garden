class_name WeatherAbilityIcon
extends Node2D

const LEVEL_PREFIX := "Lv.%s"

const ICON_PREFIX := "res://resources/sprites/GUI/icons/weather_ability/icon_%s.png"
const ACTION_LIST_SCENE := preload("res://scenes/GUI/shared/descriptions/shared_description/gui_action_list.tscn")

@onready var gui_icon: GUIIcon = %GUIIcon
@onready var left_action_container: PanelContainer = %LeftActionContainer
@onready var right_action_container: PanelContainer = %RightActionContainer
@onready var level_label: Label = $LevelLabel

var tooltip_position:GUITooltip.TooltipPosition = GUITooltip.TooltipPosition.RIGHT
var _weather_ability_data:WeatherAbilityData
var _action_datas:Array[ActionData]
var _tooltip_id:String = ""

func _ready() -> void:
	gui_icon.mouse_entered.connect(_on_mouse_entered)
	gui_icon.mouse_exited.connect(_on_mouse_exited)

func setup_with_weather_ability_data(data:WeatherAbilityData, level:int) -> void:
	_weather_ability_data = data
	if level > 0:
		level_label.text = str(LEVEL_PREFIX%(level + 1))
	gui_icon.texture = load(ICON_PREFIX % _weather_ability_data.id)
	for action_data in _weather_ability_data.action_datas:
		var leveled_action_data:ActionData = action_data.get_duplicate()
		leveled_action_data.value += level
		_action_datas.append(leveled_action_data)
	var player_actions:Array[ActionData] = _action_datas.filter(func(action:ActionData): return action.action_category == ActionData.ActionCategory.PLAYER)
	var field_actions:Array[ActionData] = _action_datas.filter(func(action:ActionData): return action.action_category == ActionData.ActionCategory.FIELD)
	if not player_actions.is_empty():
		var action_list:GUIActionList = ACTION_LIST_SCENE.instantiate()
		action_list.action_alignment = GUIGeneralAction.ActionAlignment.RIGHT
		left_action_container.add_child(action_list)
		action_list.update(player_actions, null)
		left_action_container.show()

	if not field_actions.is_empty():
		var action_list:GUIActionList = ACTION_LIST_SCENE.instantiate()
		action_list.action_alignment = GUIGeneralAction.ActionAlignment.LEFT
		right_action_container.add_child(action_list)
		action_list.update(field_actions, null)
		right_action_container.show()


func _on_mouse_entered() -> void:
	gui_icon.is_highlighted = true
	gui_icon.has_outline = true
	_tooltip_id = Util.get_uuid()
	if tooltip_position == GUITooltip.TooltipPosition.RIGHT:
		Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.ACTIONS, _action_datas, _tooltip_id, right_action_container, tooltip_position))
	else:
		Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.ACTIONS, _action_datas, _tooltip_id, left_action_container, tooltip_position))

func _on_mouse_exited() -> void:
	gui_icon.is_highlighted = false
	gui_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)
