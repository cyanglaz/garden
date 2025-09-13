class_name ActionData
extends ThingData

enum ActionType {
	NONE,
	LIGHT,
	WATER,
	PEST,
	FUNGUS,
	WEATHER_SUNNY,
	WEATHER_RAINY,
	DRAW_CARD,
	DISCARD_CARD,
	RECYCLE,
	GREENHOUSE,
	SEEP,
}

enum ActionCategory {
	NONE,
	FIELD,
	WEATHER,
	CARD,
}

enum ValueType {
	NUMBER,
	NUMBER_OF_TOOL_CARDS_IN_HAND,
	RANDOM,
}

enum Special {
	ALL_FIELDS,
}

const CARD_ACTION_TYPES := [ActionType.DRAW_CARD, ActionType.DISCARD_CARD]
const FIELD_ACTION_TYPES := [ActionType.LIGHT, ActionType.WATER, ActionType.PEST, ActionType.FUNGUS, ActionType.RECYCLE, ActionType.GREENHOUSE, ActionType.SEEP]
const WEATHER_ACTION_TYPES := [ActionType.WEATHER_SUNNY, ActionType.WEATHER_RAINY]

@export var type:ActionType
@export var value:int
@export var value_type:ValueType = ValueType.NUMBER
@export var specials:Array[Special]

var action_category:ActionCategory: get = _get_action_category

func copy(other:ThingData) -> void:
	super.copy(other)
	type = other.type
	value = other.value
	value_type = other.value_type
	specials = other.specials.duplicate()

func get_duplicate() -> ThingData:
	var action_data:ActionData = ActionData.new()
	action_data.copy(self)
	return action_data

func _get_action_category() -> ActionCategory:
	if FIELD_ACTION_TYPES.has(type):
		return ActionCategory.FIELD
	elif WEATHER_ACTION_TYPES.has(type):
		return ActionCategory.WEATHER
	elif CARD_ACTION_TYPES.has(type):
		return ActionCategory.CARD
	return ActionCategory.NONE
