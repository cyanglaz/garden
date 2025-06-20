@tool
class_name GUIAttackBarShort
extends GUIAttackBar

@onready var _under_label: Label = %UnderLabel

func bind_ball_data(ball_data:BingoBallData, attack_counter:ResourcePoint) -> void:
	super.bind_ball_data(ball_data, attack_counter)
	_set_under_text(attack_counter)
	attack_counter.value_update.connect(_on_value_updated.bind(attack_counter))

func _set_under_text(attack_counter:ResourcePoint) -> void:
	_under_label.text = str(attack_counter.value, "/", attack_counter.max_value)

func _on_value_updated(attack_counter:ResourcePoint) -> void:
	_set_under_text(attack_counter)
