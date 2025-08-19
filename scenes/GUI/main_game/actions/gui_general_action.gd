class_name GUIGeneralAction
extends GUIAction

const VALUE_ICON_PATH := "res://resources/sprites/GUI/icons/cards/values/icon_"
const SIGN_ICON_PATH := "res://resources/sprites/GUI/icons/cards/signs/icon_"

const MAX_ACTION_TEXT := "MAX"

@onready var _gui_action_type_icon: GUIActionTypeIcon = %GUIActionTypeIcon
@onready var _pre_value_icon: TextureRect = %PreValueIcon
@onready var _value_icon: TextureRect = %ValueIcon
@onready var _post_value_icon: TextureRect = %PostValueIcon


func _ready() -> void:
	_pre_value_icon.hide()
	_value_icon.hide()
	_post_value_icon.hide()

func update_with_action(action_data:ActionData) -> void:
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
					_pre_value_icon.show()
					_pre_value_icon.texture = load(SIGN_ICON_PATH + "minus.png")
		ActionData.ValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
			_pre_value_icon.show()
			_pre_value_icon.texture = load(SIGN_ICON_PATH + "equals.png")
			_value_icon.show()
			_value_icon.texture = load(VALUE_ICON_PATH + "cards_in_hand.png")
		ActionData.ValueType.RANDOM:
			_value_icon.show()
			var value_id := _get_value_id(action_data.value)
			var icon_path := VALUE_ICON_PATH + value_id + ".png"
			_value_icon.texture = load(icon_path)
			_post_value_icon.show()
			_post_value_icon.texture = load(VALUE_ICON_PATH + "random.png")

func _get_value_id(value:int) -> String:
	var value_id := str(abs(value))
	if value > 10:
		value_id = "max"
	return value_id
