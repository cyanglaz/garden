class_name DescriptionParser
extends RefCounted

const IMAGE_PATH_CARD := "res://resources/sprites/GUI/icons/resources/icon_card.png"
const ICON_SIZE := 7

static func find_all_reference_pairs(formatted_description:String) -> Array:
	var pairs:Array = []
	var searching_start_index := 0
	while true:
		var start_index := formatted_description.find("{", searching_start_index)
		if start_index == -1:
			break
		var end_index := formatted_description.find("}", start_index)
		if end_index == -1:
			break
		var reference_key := formatted_description.substr(start_index + 1, end_index - start_index - 1)
		var pair := reference_key.split(":")
		if pair.size() == 2:
			pairs.append(pair)
		searching_start_index = end_index + 1
	return pairs

static func format_references(formatted_description:String, data_to_format:Dictionary, highlight_description_keys:Dictionary, additional_highlight_check:Callable, ) -> String:
	var searching_start_index := 0
	while true:
		var start_index := formatted_description.find("{", searching_start_index)
		if start_index == -1:
			break
		var end_index := formatted_description.find("}", start_index)
		if end_index == -1:
			break
		var reference_key := formatted_description.substr(start_index + 1, end_index - start_index - 1)
		var highlight:bool = additional_highlight_check.call(reference_key)
		var formatted_string := _format_reference(reference_key, data_to_format, highlight_description_keys, highlight)
		formatted_description = formatted_description.substr(0, start_index) + formatted_string + formatted_description.substr(end_index + 1)
		searching_start_index = start_index + formatted_string.length()
	return formatted_description

static func _format_reference(reference_key:String, data_to_format:Dictionary, highlight_description_keys:Dictionary, highlight:bool) -> String:
	# Find the referenced id under the umbrella id
	var parsed_string := ""
	var highlight_color := Constants.COLOR_WHITE
	var reference_parts:Array = reference_key.split(":")
	if reference_parts.size() == 1:
		if data_to_format.has(reference_key):
			parsed_string = data_to_format[reference_key]
			parsed_string = Util.convert_to_bbc_highlight_text(parsed_string, highlight_color)
	else:
		var reference_category:String = reference_parts[0]
		var reference_id:String = reference_parts[1]
		if (highlight_description_keys.has(reference_id) && highlight_description_keys[reference_id] == true) || highlight:
			highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
		if reference_category == "field_status" || reference_category == "resource" || reference_category == "action":
			parsed_string = _format_icon_reference(reference_id, highlight)
		elif reference_category == "card":
			parsed_string = _format_card_reference(reference_id, highlight)
		elif reference_category == "bordered_text":
			parsed_string = Util.convert_to_bbc_highlight_text(parsed_string, highlight_color)
	return parsed_string

static func _get_level_suffix(reference_id:String) -> String:
	var plus_sign_index := reference_id.find("+")
	if plus_sign_index == -1:
		return ""
	return reference_id.substr(plus_sign_index)

static func _format_icon_reference(reference_id:String, highlight:bool) -> String:
	var icon_string := ""
	var image_path : = ""
	
	var level_suffix := _get_level_suffix(reference_id)
	image_path = Util.get_image_path_for_resource_id(reference_id)
	var highlight_color := Constants.COLOR_WHITE
	if highlight:
		highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	icon_string = str("[img=", ICON_SIZE, "x", ICON_SIZE, "]", image_path, "[/img]") + Util.convert_to_bbc_highlight_text(level_suffix, highlight_color)
	return icon_string

static func _highlight_string(string:String) -> String:
	# Check if the string is already highlighted
	var highlight_color := Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	if string.begins_with(str("[outline_size=1][color=", Util.get_color_hex(highlight_color), "]")) && string.ends_with("[/color][/outline_size]"):
		return string
	# Check if the string is already highlighted with white
	if string.begins_with(str("[outline_size=1][color=", Util.get_color_hex(Constants.COLOR_WHITE), "]")) && string.ends_with("[/color][/outline_size]"):
		string = string.trim_prefix(str("[outline_size=1][color=", Util.get_color_hex(Constants.COLOR_WHITE), "]"))
		string = string.trim_suffix("[/color][/outline_size]")
		return Util.convert_to_bbc_highlight_text(string, highlight_color)
	assert(!string.begins_with(str("[outline_size=1]")))
	return Util.convert_to_bbc_highlight_text(string, highlight_color)

static func _format_card_reference(reference_id:String, highlight:bool) -> String:
	var highlight_color := Constants.COLOR_WHITE
	if highlight:
		highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	var icon_string = str("[img=", ICON_SIZE, "x", ICON_SIZE, "]", IMAGE_PATH_CARD, "[/img]")
	var card_name:String = Util.convert_to_bbc_highlight_text(MainDatabase.tool_database.get_data_by_id(reference_id).display_name, highlight_color)
	var final_string := str(icon_string, card_name, " ")
	return final_string
	
