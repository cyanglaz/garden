class_name GUIGeneralAction
extends GUIAction

const VALUE_ICON_PATH := "res://resources/sprites/GUI/icons/cards/values/icon_"
const SIGN_ICON_PATH := "res://resources/sprites/GUI/icons/cards/signs/icon_"
const SPECIAL_ICON_PATH := "res://resources/sprites/GUI/icons/cards/specials/icon_"

const MAX_ACTION_TEXT := "MAX"

@onready var _gui_action_type_icon: GUIActionTypeIcon = %GUIActionTypeIcon
@onready var _sign_icon: TextureRect = %SignIcon
@onready var _value_icon: TextureRect = %ValueIcon
@onready var _random_icon: TextureRect = %RandomIcon
@onready var _field_application_icon: TextureRect = %FieldApplicationIcon
@onready var _x_value_label: Label = %XValueLabel

func update_with_action(action_data:ActionData) -> void:
	_sign_icon.hide()
	_value_icon.hide()
	_random_icon.hide()
	_x_value_label.hide()
	_field_application_icon.hide()
	_gui_action_type_icon.update_with_action_type(action_data.type)
	match action_data.value_type:
		ActionData.ValueType.NUMBER:
			if action_data.value == 0:
				_value_icon.hide()
			else:
				_value_icon.show()
				var value_id := _get_value_id(action_data.value)
				var icon_path := VALUE_ICON_PATH + value_id + ".png"
				_value_icon.texture = load(icon_path)
				if action_data.value < 0:
					_sign_icon.show()
					_sign_icon.texture = load(SIGN_ICON_PATH + "minus.png")
		ActionData.ValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
			_sign_icon.show()
			_sign_icon.texture = load(SIGN_ICON_PATH + "equals.png")
			_value_icon.show()
			_value_icon.texture = load(VALUE_ICON_PATH + "cards_in_hand.png")
		ActionData.ValueType.RANDOM:
			_value_icon.show()
			var value_id := _get_value_id(action_data.value)
			var icon_path := VALUE_ICON_PATH + value_id + ".png"
			_value_icon.texture = load(icon_path)
			_random_icon.show()
		ActionData.ValueType.X:
			_value_icon.show()
			_value_icon.texture = load(VALUE_ICON_PATH + "x.png")
			_x_value_label.show()
			_x_value_label.text = "(%s)"%[_get_x_value(action_data)]
	if action_data.modified_value > 0:
		_value_icon.modulate = Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	elif action_data.modified_value < 0:
		_value_icon.modulate = Constants.TOOLTIP_HIGHLIGHT_COLOR_RED
	else:
		_value_icon.modulate = Color.WHITE
			
	for special:ActionData.Special in action_data.specials:
		match special:
			ActionData.Special.ALL_FIELDS:
				_field_application_icon.show()
				var path := SPECIAL_ICON_PATH + "all_fields.png"
				_field_application_icon.texture = load(path)
				
func update_for_x(x_value:int, x_value_type:ActionData.XValueType) -> void:
	_random_icon.hide()
	_field_application_icon.hide()
	_x_value_label.hide()
	
	_gui_action_type_icon.update_with_action_type(ActionData.ActionType.UPDATE_X)

	_sign_icon.show()
	_sign_icon.texture = load(SIGN_ICON_PATH + "equals.png")

	_value_icon.show()
	match x_value_type:
		ActionData.XValueType.NUMBER:
			_value_icon.texture = load(VALUE_ICON_PATH + str(x_value) + ".png")
		ActionData.XValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
			_value_icon.texture = load(VALUE_ICON_PATH + "cards_in_hand.png")

func _get_x_value(action_data) -> String:
	match action_data.x_value_type:
		ActionData.XValueType.NUMBER:
			return str(action_data.x_value)
		ActionData.XValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
			assert(false, "NUMBER_OF_TOOL_CARDS_IN_HAND is not implemented")
			return Util.get_localized_string("ACTION_VALUE_HAND_CARDS")
	return ""

func _get_value_id(value:int) -> String:
	var value_id := str(abs(value))
	if value > 10:
		value_id = "max"
	return value_id
