class_name GUIBingoBallDescriptionInnerBorder
extends MarginContainer

@onready var _inner_border: NinePatchRect = %InnerBorder

func update_with_ball_data(bingo_ball_data:BingoBallData) -> void:
	_inner_border.self_modulate = Util.get_color_for_rarity(bingo_ball_data.rarity)
