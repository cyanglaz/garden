class_name GUIBingoBallButton
extends GUIBasicButton

@onready var gui_bingo_ball: GUIBingoBall = %GUIBingoBall

func bind_bingo_ball(bingo_ball:BingoBallData) -> void:
	gui_bingo_ball.bind_bingo_ball(bingo_ball)
