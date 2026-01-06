class_name GUIWeatherAbilityTooltip
extends GUITooltip

const ACTION_TOOLTIP_DELAY := 0.2

@onready var to_plant_name_label: Label = %ToPlantNameLabel
@onready var to_plant_gui_action_list: GUIActionList = %ToPlantGUIActionList
@onready var to_plant_rich_text_label: RichTextLabel = %ToPlantRichTextLabel
@onready var to_player_name_label: Label = %ToPlayerNameLabel
@onready var to_player_gui_action_list: GUIActionList = %ToPlayerGUIActionList
@onready var to_player_rich_text_label: RichTextLabel = %ToPlayerRichTextLabel

var _tooltip_id:String = ""
var _valid := true

func _ready() -> void:
	super._ready()
	tool_tip_shown.connect(_on_tooltop_shown)

func _update_with_tooltip_request() -> void:
	var weather_ability_data:WeatherAbilityData = _tooltip_request.data as WeatherAbilityData
	to_plant_name_label.text = Util.get_localized_string("WEATHER_ABILITY_TO_PLANT_NAME")
	if weather_ability_data.plant_actions.is_empty():	
		to_plant_rich_text_label.text = weather_ability_data.get_display_description()
	else:
		to_plant_gui_action_list.update(weather_ability_data.plant_actions, null)
	to_player_name_label.text = Util.get_localized_string("WEATHER_ABILITY_TO_PLAYER_NAME")
	if weather_ability_data.player_actions.is_empty():
		to_player_rich_text_label.text = weather_ability_data.get_display_description()
	else:
		to_player_gui_action_list.update(weather_ability_data.player_actions, null)

func _on_tooltop_shown() -> void:
	await Util.create_scaled_timer(ACTION_TOOLTIP_DELAY).timeout
	if _valid:
		print("show actions tooltip valid: %s" % _valid)
		_show_actions_tooltip()

func _show_actions_tooltip() -> void:
	var action_datas:Array[ActionData] = []
	action_datas.append_array(_tooltip_request.data.plant_actions)
	action_datas.append_array(_tooltip_request.data.player_actions)
	if action_datas.is_empty():
		return
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.ACTIONS, action_datas, _tooltip_id, self, GUITooltip.TooltipPosition.BOTTOM))

func _hide_actions_tooltip() -> void:
	print("hide actions tooltip")
	Events.request_hide_tooltip.emit(_tooltip_id)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_valid = false
		print("notification valid: %s" % _valid)
		_hide_actions_tooltip()
