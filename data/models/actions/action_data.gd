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
	ENERGY,
	UPDATE_X,
}

enum ActionCategory {
	NONE,
	FIELD,
	WEATHER,
	CARD,
}

enum OperatorType {
	UPDATE_BY,
	EQUAL_TO,
}

enum ValueType {
	NUMBER,
	RANDOM,
	X,
}

enum XValueType {
	NUMBER,
	NUMBER_OF_TOOL_CARDS_IN_HAND,
	TARGET_LIGHT,
}

enum Special {
	ALL_FIELDS,
}

const NEED_CARD_SELECTION := [ActionType.DISCARD_CARD]
const CARD_ACTION_TYPES := [ActionType.DRAW_CARD, ActionType.DISCARD_CARD]
const FIELD_ACTION_TYPES := [ActionType.LIGHT, ActionType.WATER, ActionType.PEST, ActionType.FUNGUS, ActionType.RECYCLE, ActionType.GREENHOUSE, ActionType.SEEP]
const WEATHER_ACTION_TYPES := [ActionType.WEATHER_SUNNY, ActionType.WEATHER_RAINY]

@export var type:ActionType
@export var value:int:set = _set_value, get = _get_value
@export var value_type:ValueType = ValueType.NUMBER
@export var operator_type:OperatorType = OperatorType.UPDATE_BY
@export var specials:Array[Special]
@export var x_value:int:set = _set_x_value, get = _get_x_value
@export var x_value_type:XValueType = XValueType.NUMBER

var action_category:ActionCategory: get = _get_action_category
var modified_value:int
var modified_x_value:int
var _original_value:int
var _original_x_value:int

func copy(other:ThingData) -> void:
	super.copy(other)
	type = other.type
	value = other.value
	value_type = other.value_type
	specials = other.specials.duplicate()
	modified_value = other.modified_value
	operator_type = other.operator_type
	x_value = other.x_value
	x_value_type = other.x_value_type
	_original_value = other._original_value
	modified_x_value = other.modified_x_value
	_original_x_value = other._original_x_value

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

func _set_value(val:int) -> void:
	_original_value = val

func _get_value() -> int:
	match value_type:
		ValueType.NUMBER:
			return modified_value + _original_value
		ValueType.RANDOM:
			return -1
		ValueType.X:
			return x_value
	return modified_value + _original_value

func _set_x_value(val:int) -> void:
	_original_x_value = val

func _get_x_value() -> int:
	var base_x_value := 0
	match x_value_type:
		XValueType.NUMBER:
			base_x_value = _original_x_value
		XValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
			if Singletons.main_game.tool_manager:
				# -1 to exclude the selected tool
				base_x_value = Singletons.main_game.tool_manager.tool_deck.hand.size() - 1
	return modified_x_value + base_x_value
