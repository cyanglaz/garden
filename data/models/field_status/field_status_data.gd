class_name FieldStatusData
extends ThingData

enum Type {
	BAD,
	GOOD,
}

@export var type:Type
@export var popup_message:String
@export var stackable:bool
@export var single_turn:bool
@export var reduce_stack_on_turn_end:bool
@export var reduce_stack_on_trigger:bool

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
	stackable = other_field_status_data.stackable
	single_turn = other_field_status_data.single_turn
	reduce_stack_on_turn_end = other_field_status_data.reduce_stack_on_turn_end
	reduce_stack_on_trigger = other_field_status_data.reduce_stack_on_trigger

func get_duplicate() -> FieldStatusData:
	var dup:FieldStatusData = FieldStatusData.new()
	dup.copy(self)
	return dup

func _get_status_script() -> FieldStatusScript:
	if _status_script:
		return _status_script
	return _create_status_script()

func _create_status_script() -> FieldStatusScript:
	var path := Util.get_script_path_for_field_status_id(id)
	if ResourceLoader.exists(path):
		_status_script = load(path).new(self)
		_status_script.status_data = self
	return _status_script
