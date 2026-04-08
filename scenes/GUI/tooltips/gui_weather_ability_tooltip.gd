class_name GUIWeatherAbilityTooltip
extends GUITooltip

@onready var _title_label: Label = %TitleLabel
@onready var _player_gui_action_list: GUIActionList = %PlayerGUIActionList
@onready var _plant_gui_action_list: GUIActionList = %PlantGUIActionList

func _update_with_tooltip_request() -> void:
	var weather_ability_data: WeatherAbilityData = _tooltip_request.data as WeatherAbilityData
	_title_label.text = weather_ability_data.get_display_name()

	var action_datas: Array = _tooltip_request.additional_data.get("action_datas", [])
	var player_actions: Array[ActionData] = []
	var field_actions: Array[ActionData] = []
	for a: ActionData in action_datas:
		if a.action_category == ActionData.ActionCategory.PLAYER:
			player_actions.append(a)
		elif a.action_category == ActionData.ActionCategory.FIELD:
			field_actions.append(a)

	if not player_actions.is_empty():
		_player_gui_action_list.update(player_actions, null)
	if not field_actions.is_empty():
		_plant_gui_action_list.update(field_actions, null)
