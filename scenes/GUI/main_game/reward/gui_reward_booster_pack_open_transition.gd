class_name GUIRewardBoosterPackOpenTransition
extends Control

const SCALE_FACTOR:float = 1.5

signal transition_finished()

@onready var gui_booster_pack_icon: GUIBoosterPackIcon = $GUIBoosterPackIcon

var booster_pack_button_rect:Rect2

func start_transition_animation_with_type(booster_pack_type:ContractData.BoosterPackType, g_position:Vector2) -> void:
	gui_booster_pack_icon.update_with_booster_pack_type(booster_pack_type)
	gui_booster_pack_icon.global_position = g_position
	gui_booster_pack_icon.pivot_offset = gui_booster_pack_icon.size/2
	gui_booster_pack_icon.has_outline = true
	booster_pack_button_rect = Rect2(g_position, gui_booster_pack_icon.size)
	show()
	var tween := Util.create_scaled_tween(self)
	# tween.tween_property(gui_booster_pack_icon, "global_position", g_position + Vector2(0, -gui_booster_pack_icon.size.y/2), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(gui_booster_pack_icon, "scale", Vector2.ONE * SCALE_FACTOR, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	transition_finished.emit()
