class_name ActionData
extends ThingData

enum ActionType {
	NONE,
	LIGHT,
	WATER,
	PEST,
	FUNGUS,
	GLOW,
	RAIN,
}

@export var type:ActionType
@export var value:int
@export var time_length:int
@export var target_count:int = 1

func copy(other:ThingData) -> void:
	super.copy(other)
	type = other.type
	value = other.value
	time_length = other.time_length
	target_count = other.target_count

func get_duplicate() -> ThingData:
	var action_data:ActionData = ActionData.new()
	action_data.copy(self)
	return action_data
	
func get_display_description() -> String:
	var formatted_description := description.format(data)
	return formatted_description
