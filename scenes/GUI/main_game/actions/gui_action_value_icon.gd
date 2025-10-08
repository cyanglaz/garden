class_name GUIActionValueIcon
extends HBoxContainer

const VALUE_ICON_PATH := "res://resources/sprites/GUI/icons/cards/values/icon_"
const SIGN_ICON_PATH := "res://resources/sprites/GUI/icons/cards/signs/icon_"

@onready var _sign_icon: TextureRect = %SignIcon
@onready var _value_icon: TextureRect = %ValueIcon
@onready var _random_icon: TextureRect = %RandomIcon
@onready var _x_value_label: Label = %XValueLabel
@onready var _number_sign_icon: TextureRect = %NumberSignIcon

func update_with_action(action_data:ActionData) -> void:
	_sign_icon.hide()
	_value_icon.hide()
	_random_icon.hide()
	_x_value_label.hide()
	_number_sign_icon.hide()
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
	
	if !_sign_icon.visible && !_value_icon.visible && !_random_icon.visible && !_x_value_label.visible && !_number_sign_icon.visible:
		hide()
	else:
		show()

func update_for_x(x_value:int, x_value_type:ActionData.XValueType) -> void:
	_random_icon.hide()
	_x_value_label.hide()
	_number_sign_icon.hide()
	_sign_icon.show()
	_sign_icon.texture = load(SIGN_ICON_PATH + "equals.png")

	_value_icon.show()
	match x_value_type:
		ActionData.XValueType.NUMBER:
			if x_value < 0:
				_number_sign_icon.show()
				_number_sign_icon.texture = load(SIGN_ICON_PATH + "minus.png")
			_value_icon.texture = load(VALUE_ICON_PATH + str(abs(x_value)) + ".png")
		ActionData.XValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
			_value_icon.texture = load(VALUE_ICON_PATH + "cards_in_hand.png")
	
	if !_sign_icon.visible && !_value_icon.visible && !_random_icon.visible && !_x_value_label.visible && !_number_sign_icon.visible:
		hide()
	else:
		show()

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
