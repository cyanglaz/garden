# Basic class for all custom resource data classes.
class_name ThingData
extends Resource

enum ReferenceType {
	STATUS_EFFECT,
	SPACE_EFFECT,
	RESOURCE,
	OTHER,
}

@export var id:String
@export var display_name:String
@export_multiline var description:String
@export var data:Dictionary

var upgrade_to_id:String: get = _get_upgrade_to_id
var upgraded_from_id:String: get = _get_upgraded_from_id
var base_id:String: get = _get_base_id
var level:int: get = _get_level

var highlight_description_keys:Dictionary = {}

var _original_resource_path:String
@warning_ignore("unused_private_class_variable")
var _snapshot := Snapshot.new(self, [])

func copy(other:ThingData) -> void:
	if other.resource_path.is_empty():
		assert(!other._original_resource_path.is_empty())
		_original_resource_path = other._original_resource_path
	else:
		_original_resource_path = other.resource_path
	id = other.id
	description = other.description
	data = other.data.duplicate()
	display_name = other.display_name

func get_duplicate() -> ThingData:
	var dup:ThingData = ThingData.new()
	dup.copy(self)
	return dup

func get_display_description() -> String:
	var formatted_description := description
	formatted_description = _formate_references(formatted_description, data, _additional_highlight_check) 
	return formatted_description

func _additional_highlight_check(_reference_id:String) -> bool:
	return false

func _formate_references(formatted_description:String, data_to_format:Dictionary, additional_highlight_check:Callable) -> String:
	var searching_start_index := 0
	while true:
		var start_index := formatted_description.find("{", searching_start_index)
		if start_index == -1:
			break
		var end_index := formatted_description.find("}", start_index)
		if end_index == -1:
			break
		var reference_id := formatted_description.substr(start_index + 1, end_index - start_index - 1)
		var highlight:bool = additional_highlight_check.call(reference_id)
		var formatted_string := _format_reference(reference_id, data_to_format, highlight)
		formatted_description = formatted_description.substr(0, start_index) + formatted_string + formatted_description.substr(end_index + 1)
		searching_start_index = start_index + formatted_string.length()
	return formatted_description

func _format_reference(reference_id:String, data_to_format:Dictionary, highlight:bool) -> String:
	# Find the referenced id under the umbrella id
	var parsed_string := ""
	var highlight_color := Constants.COLOR_WHITE
	if (highlight_description_keys.has(reference_id) && highlight_description_keys[reference_id] == true) || highlight:
		highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	if reference_id.begins_with("icon_"):
		parsed_string = _format_icon_reference(reference_id, highlight)
	elif data_to_format.has(reference_id):
		parsed_string = data_to_format[reference_id]
		parsed_string = Util.convert_to_bbc_highlight_text(parsed_string, highlight_color)
	elif reference_id.begins_with("bordered_text:"):
		reference_id = reference_id.trim_prefix("bordered_text:")
		parsed_string = Util.convert_to_bbc_highlight_text(parsed_string, highlight_color)
	return parsed_string

func _format_icon_reference(reference_id:String, highlight:bool) -> String:
	reference_id = reference_id.trim_prefix("icon_")
	var icon_string := ""
	var image_path : = ""
	var reference_type:ReferenceType = ReferenceType.OTHER

	# For each reference id, create an icon tag, append to the final string with , separated
	if reference_id.begins_with("status_effect_"):
		reference_type = ReferenceType.STATUS_EFFECT
	elif reference_id.begins_with("space_effect_"):
		reference_type = ReferenceType.SPACE_EFFECT
	elif reference_id.begins_with("resource_"):
		reference_type = ReferenceType.RESOURCE
	
	var url_prefix := ""
	var url := ""
	var level_suffix := _get_level_suffix(reference_id)
	match reference_type:
		ReferenceType.STATUS_EFFECT:
			url_prefix = "status_effect_"
			reference_id = reference_id.trim_prefix("status_effect_")
			image_path = Util.get_image_path_for_status_effect_id(reference_id)
			url = reference_id
		ReferenceType.SPACE_EFFECT:
			url_prefix = "space_effect_"
			reference_id = reference_id.trim_prefix("space_effect_")
			image_path = Util.get_image_path_for_space_effect_id(reference_id)
			url = reference_id
		ReferenceType.RESOURCE:
			reference_id = reference_id.trim_prefix("resource_")
			image_path = Util.get_image_path_for_resource_id(reference_id)
		ReferenceType.OTHER:
			url_prefix = "ball_"
			image_path = Util.get_image_path_for_ball_id(reference_id)
			url = reference_id
	var highlight_color := Constants.COLOR_WHITE
	if highlight:
		highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	icon_string = str("[img=6x6]", image_path, "[/img]") + Util.convert_to_bbc_highlight_text(level_suffix, highlight_color)
	if !url.is_empty():
		icon_string = str("[url=", url_prefix, reference_id, "]", icon_string, "[/url]")
	return icon_string

func _get_level_suffix(reference_id:String) -> String:
	var plus_sign_index := reference_id.find("+")
	if plus_sign_index == -1:
		return ""
	return reference_id.substr(plus_sign_index)

func _highlight_string(string:String) -> String:
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

func _get_level() -> int:
	var plus_sign_index := id.find("+")
	if plus_sign_index == -1:
		return 0
	return id.substr(plus_sign_index + 1).to_int()

func _get_base_id() -> String:
	var plus_sign_index := id.find("+")
	if plus_sign_index == -1:
		return id
	return id.substr(0, plus_sign_index)

func _get_upgrade_to_id() -> String:
	return base_id + "+" + str(level + 1)

func _get_upgraded_from_id() -> String:
	if level == 0:
		return ""
	if level == 1:
		return base_id
	return base_id + "+" + str(level - 1)
