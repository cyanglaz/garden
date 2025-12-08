class_name ActionDescriptionFormulator
extends RefCounted

const FIELD_STATUS_ACTION_TYPES := [ActionData.ActionType.PEST, ActionData.ActionType.FUNGUS, ActionData.ActionType.RECYCLE, ActionData.ActionType.GREENHOUSE, ActionData.ActionType.DEW]

const HIGHLIGHT_COLOR := Constants.COLOR_WHITE
const X_DESCRIPTION_HIGHLIGHT_COLOR := Constants.COLOR_BLUE_3

static func get_action_description(action_data:ActionData, target_plant:Plant) -> String:
	var thing_data:ThingData = action_data
	if action_data.type in FIELD_STATUS_ACTION_TYPES:
		var id := Util.get_action_id_with_action_type(action_data.type)
		var field_status_data:FieldStatusData = MainDatabase.field_status_database.get_data_by_id(id)
		thing_data = field_status_data
	var action_description := get_raw_action_description(action_data, target_plant)
	action_description = DescriptionParser.format_references(action_description, thing_data.data.duplicate(), thing_data.highlight_description_keys, func(_reference_id:String) -> bool: return false)

	if action_description.contains("%s"):
		action_description = action_description % _get_value_text(action_data, target_plant)
	
	if action_data.value_type == ActionData.ValueType.X:
		action_description += str(Util.get_localized_string("PUNCTUATION_COMMA"), _get_x_value_text(action_data, target_plant))

	var period_string := Util.get_localized_string("PUNCTUATION_PERIOD").trim_suffix(" ")
	if !action_description.ends_with(period_string):
		action_description += period_string
	return action_description

static func get_raw_action_description(action_data:ActionData, target_plant:Plant) -> String:
	var raw_action_description := ""
	match action_data.type:
		ActionData.ActionType.LIGHT, ActionData.ActionType.WATER:
			raw_action_description = _get_field_action_description(action_data, target_plant)
		ActionData.ActionType.ENERGY, ActionData.ActionType.UPDATE_X, ActionData.ActionType.UPDATE_GOLD:
			raw_action_description = _get_resource_update_action_description(action_data, target_plant)
		ActionData.ActionType.PEST, ActionData.ActionType.FUNGUS, ActionData.ActionType.RECYCLE, ActionData.ActionType.GREENHOUSE, ActionData.ActionType.DEW:
			raw_action_description = _get_field_status_description(action_data)
		ActionData.ActionType.WEATHER_SUNNY, ActionData.ActionType.WEATHER_RAINY:
			raw_action_description = _get_weather_action_description(action_data)
		ActionData.ActionType.DRAW_CARD:
			raw_action_description = _get_draw_card_action_description(action_data, target_plant)
		ActionData.ActionType.DISCARD_CARD:
			raw_action_description = _get_discard_card_action_description(action_data, target_plant)
		ActionData.ActionType.NONE:
			pass
	return raw_action_description

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
	return special_description

static func _get_field_action_description(action_data:ActionData, target_plant:Plant) -> String:
	var main_description := _get_action_plant_value_update_description(action_data, target_plant)
	var field_string := ""
	if action_data.specials.has(ActionData.Special.ALL_FIELDS):
		if action_data.get_calculated_value(target_plant) >= 0:
			field_string = Util.get_localized_string("ACTION_ADD_TO_ALL_FIELDS_TEXT")
		else:
			field_string = Util.get_localized_string("ACTION_REDUCE_FROM_ALL_FIELDS_TEXT")
	else:
		if action_data.get_calculated_value(target_plant) >= 0:
			field_string = Util.get_localized_string("ACTION_ADD_TO_ONE_FIELDS_TEXT")
		else:
			field_string = Util.get_localized_string("ACTION_REDUCE_FROM_ONE_FIELDS_TEXT")
	main_description += Util.convert_to_bbc_highlight_text(field_string, HIGHLIGHT_COLOR)
	return main_description

static func _get_action_plant_value_update_description(action_data:ActionData, target_plant:Plant) -> String:
	var main_description := ""
	var action_name := Util.get_action_name_from_action_type(action_data.type)
	action_name = Util.convert_to_bbc_highlight_text(action_name, HIGHLIGHT_COLOR)
	match action_data.operator_type:
		ActionData.OperatorType.INCREASE:
			main_description = Util.get_localized_string("ACTION_PLANT_VALUE_DESCRIPTION_INCREASE")
			main_description = main_description % [_get_value_text(action_data, target_plant), action_name]
		ActionData.OperatorType.DECREASE:
			main_description = Util.get_localized_string("ACTION_PLANT_VALUE_DESCRIPTION_DECREASE")
			main_description = main_description % [_get_value_text(action_data, target_plant), action_name]
		ActionData.OperatorType.EQUAL_TO:
			main_description = Util.get_localized_string("ACTION_VALUE_DESCRIPTION_EQUAL")
			main_description = main_description % [action_name, _get_value_text(action_data, target_plant)]
	return main_description

static func _get_resource_update_action_description(action_data:ActionData, target_plant:Plant) -> String:
	var main_description := _get_action_resource_value_update_description(action_data, target_plant)
	return main_description

static func _get_action_resource_value_update_description(action_data:ActionData, target_plant:Plant) -> String:
	var main_description := ""
	var action_name := Util.get_action_name_from_action_type(action_data.type)
	action_name = Util.convert_to_bbc_highlight_text(action_name, HIGHLIGHT_COLOR)
	match action_data.operator_type:
		ActionData.OperatorType.INCREASE:
			main_description = Util.get_localized_string("ACTION_RESOURCE_VALUE_DESCRIPTION_INCREASE")
			main_description = main_description % [action_name, _get_value_text(action_data, target_plant)]
		ActionData.OperatorType.DECREASE:
			main_description = Util.get_localized_string("ACTION_RESOURCE_VALUE_DESCRIPTION_DECREASE")
			main_description = main_description % [action_name, _get_value_text(action_data, target_plant)]
		ActionData.OperatorType.EQUAL_TO:
			main_description = Util.get_localized_string("ACTION_VALUE_DESCRIPTION_EQUAL")
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

static func _get_draw_card_action_description(action_data:ActionData, target_plant:Plant) -> String:
	var main_description := Util.get_localized_string("ACTION_DESCRIPTION_DRAW_CARD")
	main_description = main_description % [_get_value_text(action_data, target_plant)]
	return main_description

static func _get_discard_card_action_description(action_data:ActionData, target_plant:Plant) -> String:
	var main_description := Util.get_localized_string("ACTION_DESCRIPTION_DISCARD_CARD")
	main_description = main_description % [_get_value_text(action_data, target_plant)]
	return main_description

static func _get_value_text(action_data:ActionData, target_plant:Plant) -> String:
	var value_text := ""
	var highlight_color := HIGHLIGHT_COLOR
	if action_data.modified_value > 0:
		highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	elif action_data.modified_value < 0:
		highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_RED
	match action_data.value_type:
		ActionData.ValueType.NUMBER:
			var abs_value:int = action_data.get_calculated_value(target_plant)
			value_text = Util.convert_to_bbc_highlight_text(str(abs_value), highlight_color)
		ActionData.ValueType.RANDOM:
			var abs_value:int = action_data.get_calculated_value(target_plant)
			assert(abs_value > 0, "Random value must be greater than 0")
			value_text = Util.convert_to_bbc_highlight_text(str(abs_value), HIGHLIGHT_COLOR)
			value_text += Util.convert_to_bbc_highlight_text(Util.get_localized_string("ACTION_VALUE_RANDOM"), highlight_color)
		ActionData.ValueType.X:
			value_text = Util.convert_to_bbc_highlight_text(Util.get_localized_string("ACTION_VALUE_X"), X_DESCRIPTION_HIGHLIGHT_COLOR)
		_:
			assert(false, "Invalid value type: %s" % action_data.value_type)
	return value_text

static func _get_x_value_text(action_data:ActionData, target_plant:Plant) -> String:
	var main_description := Util.get_localized_string("ACTION_X_DESCRIPTION")
	var x_value_text := ""
	match action_data.x_value_type:
		ActionData.XValueType.NUMBER:
			x_value_text = str(action_data.get_calculated_x_value(target_plant))
		ActionData.XValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
			x_value_text = Util.get_localized_string("ACTION_VALUE_HAND_CARDS")
		ActionData.XValueType.TARGET_LIGHT:
			x_value_text = Util.get_localized_string("ACTION_VALUE_TARGET_LIGHT")
		_:
			assert(false, "Invalid x value type: %s" % action_data.x_value_type)
	main_description = main_description % [x_value_text]
	main_description = Util.convert_to_bbc_highlight_text(main_description, X_DESCRIPTION_HIGHLIGHT_COLOR)
	return main_description

static func _get_field_status_description(action_data:ActionData) -> String:
	var id := Util.get_action_id_with_action_type(action_data.type)
	var field_status_data:FieldStatusData = MainDatabase.field_status_database.get_data_by_id(id)
	if !field_status_data:
		return ""
	return field_status_data.description
