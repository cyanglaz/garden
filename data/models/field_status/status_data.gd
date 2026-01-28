class_name StatusData
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
@export var remove_on_trigger:bool

var stack:int: set = _set_stack

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_field_status_data := other as StatusData
	type = other_field_status_data.type
	popup_message = other_field_status_data.popup_message
	stackable = other_field_status_data.stackable
	single_turn = other_field_status_data.single_turn
	reduce_stack_on_turn_end = other_field_status_data.reduce_stack_on_turn_end
	reduce_stack_on_trigger = other_field_status_data.reduce_stack_on_trigger
	remove_on_trigger = other_field_status_data.remove_on_trigger
	stack = other_field_status_data.stack

func get_duplicate() -> StatusData:
	var dup:StatusData = StatusData.new()
	dup.copy(self)
	return dup

func _set_stack(value:int) -> void:
	stack = value
	data["stack"] = str(value)
