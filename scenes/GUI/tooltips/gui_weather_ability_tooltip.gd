class_name GUIWeatherAbilityTooltip
extends GUITooltip

@onready var _title_label: Label = %TitleLabel
@onready var to_plant_name_label: Label = %ToPlantNameLabel
@onready var to_plant_gui_action_list: GUIActionList = %ToPlantGUIActionList
@onready var to_plant_rich_text_label: RichTextLabel = %ToPlantRichTextLabel
@onready var to_player_name_label: Label = %ToPlayerNameLabel
@onready var to_player_gui_action_list: GUIActionList = %ToPlayerGUIActionList
@onready var to_player_rich_text_label: RichTextLabel = %ToPlayerRichTextLabel

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

	to_player_name_label.text = Util.get_localized_string("WEATHER_ABILITY_TO_PLAYER_NAME")
	if player_actions.is_empty():
		to_player_rich_text_label.text = weather_ability_data.get_display_description()
	else:
		to_player_gui_action_list.update(player_actions, null)

	to_plant_name_label.text = Util.get_localized_string("WEATHER_ABILITY_TO_PLANT_NAME")
	if field_actions.is_empty():
		to_plant_rich_text_label.text = weather_ability_data.get_display_description()
	else:
		to_plant_gui_action_list.update(field_actions, null)
