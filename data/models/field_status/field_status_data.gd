class_name FieldStatusData
extends ThingData

enum Type {
	BAD,
	GOOD,
}

@export var type:Type
@export var popup_message:String

var status_script:FieldStatusScript: get = _get_status_script

var stack := 0

var _status_script:FieldStatusScript

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_field_status_data := other as FieldStatusData
	stack = other_field_status_data.stack
	type = other_field_status_data.type
	popup_message = other_field_status_data.popup_message
	_status_script = _create_status_script()

func get_duplicate() -> FieldStatusData:
	var dup:FieldStatusData = FieldStatusData.new()
	dup.copy(self)
	return dup

func get_display_description() -> String:
	var formatted_description := description
	formatted_description = _formate_references(formatted_description, data, func(_reference_id:String) -> bool:
		return false
	)
	return formatted_description

func _get_status_script() -> FieldStatusScript:
	if _status_script:
		return _status_script
	return _create_status_script()

func _create_status_script() -> FieldStatusScript:
	var path := Util.get_script_path_for_field_status_id(id)
	if ResourceLoader.exists(path):
		_status_script = load(path).new(self)
	return _status_script
