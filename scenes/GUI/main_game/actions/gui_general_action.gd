class_name GUIGeneralAction
extends GUIAction

const VALUE_ICON_PATH := "res://resources/sprites/GUI/icons/cards/values/icon_"
const SIGN_ICON_PATH := "res://resources/sprites/GUI/icons/cards/signs/icon_"

const MAX_ACTION_TEXT := "MAX"

@onready var _gui_action_type_icon: GUIActionTypeIcon = %GUIActionTypeIcon
@onready var _sign_icon: TextureRect = %SignIcon
@onready var _value_icon: TextureRect = %ValueIcon

func _ready() -> void:
	_sign_icon.hide()
	_value_icon.hide()

func update_with_action(action_data:ActionData) -> void:
	_gui_action_type_icon.update_with_action_type(action_data.type)
	match action_data.value_type:
		ActionData.ValueType.NUMBER:
			if action_data.value == 0:
				_value_icon.hide()
			else:
				_value_icon.show()
				var value_id := str(abs(action_data.value))
				if action_data.value > 10:
					value_id = "max"
				else:
					var icon_path := VALUE_ICON_PATH + value_id + ".png"
					_value_icon.texture = load(icon_path)
					if action_data.value < 0:
						_sign_icon.show()
						_sign_icon.texture = load(SIGN_ICON_PATH + "minus.png")
		ActionData.ValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
			_sign_icon.show()
			_value_icon.show()
			_sign_icon.texture = load(SIGN_ICON_PATH + "equals.png")
			_value_icon.texture = load(VALUE_ICON_PATH + "cards_in_hand.png")
		ActionData.ValueType.RANDOM:
			_value_icon.show()
			_value_icon.texture = load(VALUE_ICON_PATH + "random.png")
