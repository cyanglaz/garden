class_name GUICardRewardButton
extends GUIBasicButton

@onready var _gui_ball_description: GUIBallDescription = %GUIBallDescription
@onready var _gui_bingo_ball_description_inner_border: GUIBingoBallDescriptionInnerBorder = %GUIBingoBallDescriptionInnerBorder
@onready var _border: NinePatchRect = %Border

func bind_bingo_ball_data(bingo_ball_data:BingoBallData, show_comparison:bool = false) -> void:
	_gui_ball_description.bind_bingo_ball_data(bingo_ball_data, show_comparison)
	_gui_bingo_ball_description_inner_border.update_with_ball_data(bingo_ball_data)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	match button_state:
		ButtonState.NORMAL, ButtonState.PRESSED, ButtonState.DISABLED, ButtonState.SELECTED:
			_border.self_modulate = Constants.COLOR_BLACK
		ButtonState.HOVERED:
			_border.self_modulate = Constants.COLOR_WHITE
