class_name ActionData
extends ThingData

enum ActionType {
	NONE,
	LIGHT,
	WATER,
	PEST,
	FUNGUS,
	GLOW,
	WEATHER_SUNNY,
	WEATHER_RAINY,
}

enum ActionCategory {
	NONE,
	FIELD,
	WEATHER,
}

const FIELD_ACTION_TYPES := [ActionType.LIGHT, ActionType.WATER, ActionType.PEST, ActionType.FUNGUS, ActionType.GLOW]
const WEATHER_ACTION_TYPES := [ActionType.WEATHER_SUNNY, ActionType.WEATHER_RAINY]

@export var type:ActionType
@export var value:int
@export var target_count:int = 1

var action_category:ActionCategory: get = _get_action_category

func copy(other:ThingData) -> void:
	super.copy(other)
	type = other.type
	value = other.value
	target_count = other.target_count

func get_duplicate() -> ThingData:
	var action_data:ActionData = ActionData.new()
	action_data.copy(self)
	return action_data
	
func get_display_description() -> String:
	var formatted_description := description.format(data)
	return formatted_description

func _get_action_category() -> ActionCategory:
	if FIELD_ACTION_TYPES.has(type):
		return ActionCategory.FIELD
	elif WEATHER_ACTION_TYPES.has(type):
		return ActionCategory.WEATHER
	return ActionCategory.NONE
