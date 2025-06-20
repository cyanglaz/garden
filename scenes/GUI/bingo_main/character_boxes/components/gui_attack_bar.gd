@tool
class_name GUIAttackBar
extends GUIRPBar

@onready var _gui_attack_icon: GUIAttackIcon = %GUIAttackIcon

func bind_ball_data(ball_data:BingoBallData, attack_counter:ResourcePoint) -> void:
	_gui_attack_icon.bind_ball_data(ball_data)
	bind_with_rp(attack_counter)

func get_symbol_position() -> Vector2:
	return _gui_attack_icon.global_position
