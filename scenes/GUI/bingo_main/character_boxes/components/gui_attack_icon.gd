class_name GUIAttackIcon
extends PanelContainer

@onready var _gui_bingo_ball: GUIBingoBall = %GUIBingoBall
@onready var _attack_count: Label = %AttackCount

func bind_ball_data(ball_data:BingoBallData) -> void:
	_gui_bingo_ball.bind_bingo_ball(ball_data)
	_attack_count.text = str(ball_data.attack_ball_count)
