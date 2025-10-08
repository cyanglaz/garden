class_name ActionDescriptionFormulator
extends RefCounted

const HIGHLIGHT_COLOR := Constants.COLOR_WHITE

static func get_action_description(action_data:ActionData) -> String:
	var action_description := ""
	match action_data.type:
		ActionData.ActionType.LIGHT, ActionData.ActionType.WATER, ActionData.ActionType.UPDATE_X:
			action_description = _get_field_action_description(action_data)
		ActionData.ActionType.PEST, ActionData.ActionType.FUNGUS, ActionData.ActionType.RECYCLE, ActionData.ActionType.GREENHOUSE, ActionData.ActionType.SEEP:
			#action_description = _get_field_action_description(action_data)
			#action_description += "\n\n"
			action_description = _get_field_status_description(action_data)
		ActionData.ActionType.WEATHER_SUNNY, ActionData.ActionType.WEATHER_RAINY:
			action_description = _get_weather_action_description(action_data)
		ActionData.ActionType.DRAW_CARD:
			action_description = _get_draw_card_action_description(action_data)
		ActionData.ActionType.DISCARD_CARD:
			action_description = _get_discard_card_action_description(action_data)
		ActionData.ActionType.ENERGY:
			action_description = _get_energy_action_description(action_data)
		ActionData.ActionType.NONE:
			pass
	if action_description.contains("%s"):
		action_description = action_description % _get_value_text(action_data)
	return action_description

static func get_special_name(special:ToolData.Special) -> String:
	var special_name := ""
	match special:
		ToolData.Special.USE_ON_DRAW:
			special_name = Util.get_localized_string("CARD_SPECIAL_NAME_ON_DRAW")
		ToolData.Special.COMPOST:
			special_name = Util.get_localized_string("CARD_SPECIAL_NAME_COMPOST")
		ToolData.Special.WITHER:
			special_name = Util.get_localized_string("CARD_SPECIAL_NAME_WITHER")
		_:
			assert(false, "Invalid special: %s" % special)
	return special_name

static func get_special_description(special:ToolData.Special) -> String:
	var special_description := ""
	match special:
		ToolData.Special.USE_ON_DRAW:
			special_description = Util.get_localized_string("CARD_SPECIAL_DESCRIPTION_ON_DRAW")
		ToolData.Special.COMPOST:
			special_description = Util.get_localized_string("CARD_SPECIAL_DESCRIPTION_COMPOST")
		ToolData.Special.WITHER:
			special_description = Util.get_localized_string("CARD_SPECIAL_DESCRIPTION_WITHER")
		_:
			assert(false, "Invalid special: %s" % special)
	if !special_description.ends_with("."):
		special_description += "."
	return special_description

static func _get_field_action_description(action_data:ActionData) -> String:
	var increase_description := Util.get_localized_string("ACTION_DESCRIPTION_INCREASE")
	var decrease_description := Util.get_localized_string("ACTION_DESCRIPTION_DECREASE")
	var action_name := Util.get_action_name_from_action_type(action_data.type)
	var increase := action_data.value > 0 || action_data.value_type != ActionData.ValueType.NUMBER
	action_name = Util.convert_to_bbc_highlight_text(action_name, HIGHLIGHT_COLOR)
	var main_description := ""
	if increase:
		main_description = increase_description
	else:
		main_description = decrease_description
	main_description = main_description % [action_name, _get_value_text(action_data)]
	for special:ActionData.Special in action_data.specials:
		match special:
			ActionData.Special.ALL_FIELDS:
				var all_fields_string := Util.get_localized_string("ACTION_ALL_FIELDS_TEXT")
				main_description += Util.convert_to_bbc_highlight_text(all_fields_string, HIGHLIGHT_COLOR)
	if !main_description.ends_with("."):
		main_description += "."
	return main_description

static func _get_weather_action_description(action_data:ActionData) -> String:
	var weather_name := ""
	match action_data.type:
		ActionData.ActionType.WEATHER_SUNNY:
			weather_name = "sunny"
		ActionData.ActionType.WEATHER_RAINY:
			weather_name = "rainy"
		_:
			assert(false, "Invalid action type: %s" % action_data.type)
	weather_name = str("{weather:", weather_name, "}")
	var main_description := Util.get_localized_string("ACTION_DESCRIPTION_CHANGE_WEATHER")
	main_description = main_description % [weather_name]
	return main_description

static func _get_draw_card_action_description(action_data:ActionData) -> String:
	var main_description := Util.get_localized_string("ACTION_DESCRIPTION_DRAW_CARD")
	main_description = main_description % [_get_value_text(action_data)]
	return main_description

static func _get_discard_card_action_description(action_data:ActionData) -> String:
	var main_description := Util.get_localized_string("ACTION_DESCRIPTION_DISCARD_CARD")
	main_description = main_description % [_get_value_text(action_data)]
	return main_description

static func _get_energy_action_description(action_data:ActionData) -> String:
	var main_description := Util.get_localized_string("ACTION_DESCRIPTION_ENERGY")
	main_description = main_description % [_get_value_text(action_data)]
	return main_description

static func _get_value_text(action_data:ActionData) -> String:
	var value_text := ""
	var highlight_color := HIGHLIGHT_COLOR
	if action_data.modified_value > 0:
		highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	elif action_data.modified_value < 0:
		highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_RED
	match action_data.value_type:
		ActionData.ValueType.NUMBER:
			value_text =  Util.convert_to_bbc_highlight_text(str(abs(action_data.value)), highlight_color)
		ActionData.ValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
			value_text =  Util.convert_to_bbc_highlight_text(Util.get_localized_string(("ACTION_VALUE_HAND_CARDS")), highlight_color)
		ActionData.ValueType.RANDOM:
			value_text = Util.convert_to_bbc_highlight_text(str(abs(action_data.value)), HIGHLIGHT_COLOR)
			value_text += Util.convert_to_bbc_highlight_text(Util.get_localized_string("ACTION_VALUE_RANDOM"), highlight_color)
		ActionData.ValueType.X:
			var x_value_string := Util.get_localized_string("ACTION_VALUE_X") % [_get_x_value_text(action_data)]
			value_text = DescriptionParser.format_references(x_value_string, {}, {}, func(_reference_id:String) -> bool: return false)
		_:
			assert(false, "Invalid value type: %s" % action_data.value_type)
	return value_text

static func _get_x_value_text(action_data:ActionData) -> String:
	var x_value_text := ""
	match action_data.x_value_type:
		ActionData.XValueType.NUMBER:
			x_value_text = str(action_data.x_value)
		ActionData.XValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
			x_value_text = Util.get_localized_string("ACTION_VALUE_HAND_CARDS")
	return x_value_text

static func _get_field_status_description(action_data:ActionData) -> String:
	var id := Util.get_action_id_with_action_type(action_data.type)
	var field_status_data:FieldStatusData = MainDatabase.field_status_database.get_data_by_id(id)
	if !field_status_data:
		return ""
	return field_status_data.description
