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
@export_multiline var description:String:get = _get_description
@export var data:Dictionary
@export_multiline var note:String

var name_postfix:String = ""
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

func get_display_name() -> String:
	if name_postfix.is_empty():
		return display_name
	else:
		return display_name + name_postfix

func get_display_description() -> String:
	var formatted_description := description
	formatted_description = DescriptionParser.format_references(formatted_description, data, highlight_description_keys, _additional_highlight_check)
	return formatted_description

func _additional_highlight_check(_reference_id:String) -> bool:
	return false

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

func _get_description() -> String:
	return description
