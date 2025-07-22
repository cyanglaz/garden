class_name GUIOneActionDescription
extends VBoxContainer

const HIGHLIGHT_COLOR := Constants.COLOR_WHITE

@onready var texture_rect: TextureRect = %TextureRect
@onready var title_label: Label = %TitleLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func update_with_action_data(action_data:ActionData) -> void:
	var resource_id := Util.get_action_id_with_action_type(action_data.type)
	title_label.text = _get_action_name(action_data)
	rich_text_label.text = _get_action_description(action_data)
	texture_rect.texture = load(Util.get_image_path_for_resource_id(resource_id))

func _get_action_name(action_data:ActionData) -> String:
	var action_name := ""
	match action_data.type:
		ActionData.ActionType.LIGHT:
			action_name = Util.get_localized_string("ACTION_NAME_LIGHT")
		ActionData.ActionType.WATER:
			action_name = Util.get_localized_string("ACTION_NAME_WATER")
		ActionData.ActionType.PEST:
			action_name = Util.get_localized_string("ACTION_NAME_PEST")
		ActionData.ActionType.FUNGUS:
			action_name = Util.get_localized_string("ACTION_NAME_FUNGUS")
		ActionData.ActionType.GLOW:
			action_name = Util.get_localized_string("ACTION_NAME_GLOW")
		ActionData.ActionType.WEATHER_SUNNY:
			action_name = Util.get_localized_string("ACTION_NAME_WEATHER_SUNNY")
		ActionData.ActionType.WEATHER_RAINY:
			action_name = Util.get_localized_string("ACTION_NAME_WEATHER_RAINY")
		ActionData.ActionType.DRAW_CARD:
			action_name = Util.get_localized_string("ACTION_NAME_DRAW_CARD")
		ActionData.ActionType.NONE:
			pass
	return action_name

func _get_action_description(action_data:ActionData) -> String:
	var action_description := ""
	match action_data.type:
		ActionData.ActionType.LIGHT:
			action_description = _get_field_action_description(action_data)
		ActionData.ActionType.WATER:
			action_description = _get_field_action_description(action_data)
		ActionData.ActionType.PEST:
			action_description = _get_field_action_description(action_data)
		ActionData.ActionType.FUNGUS:
			action_description = _get_field_action_description(action_data)
		ActionData.ActionType.GLOW:
			action_description = Util.get_localized_string("ACTION_DESCRIPTION_GLOW")
		ActionData.ActionType.WEATHER_SUNNY:
			action_description = _get_weather_action_description(action_data)
		ActionData.ActionType.WEATHER_RAINY:
			action_description = _get_weather_action_description(action_data)
		ActionData.ActionType.DRAW_CARD:
			action_description = _get_draw_card_action_description(action_data)
		ActionData.ActionType.NONE:
			pass
	if action_description.contains("%s"):
		action_description = action_description % abs(action_data.value)
	action_description = Util.formate_references(action_description, {}, {}, func(_reference_id:String) -> bool: return false)
	action_description += "."
	return action_description

func _get_field_action_description(action_data:ActionData) -> String:
	var increase_description := Util.get_localized_string("ACTION_DESCRIPTION_INCREASE")
	var decrease_description := Util.get_localized_string("ACTION_DESCRIPTION_DECREASE")
	var action_name := ""
	var value:int = abs(action_data.value)
	var increase := action_data.value > 0
	match action_data.type:
		ActionData.ActionType.LIGHT:
			action_name = Util.get_localized_string("RESOURCE_NAME_LIGHT")
		ActionData.ActionType.WATER:
			action_name = Util.get_localized_string("RESOURCE_NAME_WATER")
		ActionData.ActionType.PEST:
			action_name = Util.get_localized_string("RESOURCE_NAME_PEST")
		ActionData.ActionType.FUNGUS:
			action_name = Util.get_localized_string("RESOURCE_NAME_FUNGUS")
		_:
			assert(false, "Invalid action type: %s" % action_data.type)
	action_name = Util.convert_to_bbc_highlight_text(action_name, HIGHLIGHT_COLOR)
	var main_description := ""
	if increase:
		main_description = increase_description
	else:
		main_description = decrease_description
	var increase_value := Util.convert_to_bbc_highlight_text(str(value), HIGHLIGHT_COLOR)
	main_description = main_description % [action_name, increase_value]
	return main_description

func _get_weather_action_description(action_data:ActionData) -> String:
	var weather_name := ""
	match action_data.type:
		ActionData.ActionType.WEATHER_SUNNY:
			weather_name = Util.get_localized_string("WEATHER_NAME_SUNNY")
		ActionData.ActionType.WEATHER_RAINY:
			weather_name = Util.get_localized_string("WEATHER_NAME_RAINY")
		_:
			assert(false, "Invalid action type: %s" % action_data.type)
	weather_name = Util.convert_to_bbc_highlight_text(weather_name, HIGHLIGHT_COLOR)
	var main_description := Util.get_localized_string("ACTION_DESCRIPTION_CHANGE_WEATHER")
	main_description = main_description % [weather_name]
	return main_description

func _get_draw_card_action_description(action_data:ActionData) -> String:
	var main_description := Util.get_localized_string("ACTION_DESCRIPTION_DRAW_CARD")
	var value:int = abs(action_data.value)
	var value_text := Util.convert_to_bbc_highlight_text(str(value), HIGHLIGHT_COLOR)
	main_description = main_description % [value_text]
	return main_description
