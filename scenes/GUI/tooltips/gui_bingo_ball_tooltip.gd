class_name GUIBingoBallTooltip
extends GUITooltip

const PLAYER_BALL_COLOR := Constants.COLOR_GRAY2

@onready var _gui_ball_description: GUIBallDescription = %GUIBallDescription
@onready var _gui_bingo_ball_description_inner_border: GUIBingoBallDescriptionInnerBorder = %GUIBingoBallDescriptionInnerBorder

func bind_bingo_ball_data(bingo_ball_data:BingoBallData) -> void:
	_gui_ball_description.bind_bingo_ball_data(bingo_ball_data, false)
	_gui_bingo_ball_description_inner_border.update_with_ball_data(bingo_ball_data)

func _set_tooltip_position(val:GUITooltip.TooltipPosition) -> void:
	super._set_tooltip_position(val)
	_gui_ball_description.tooltip_position = val
