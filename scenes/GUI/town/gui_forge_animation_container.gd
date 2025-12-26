class_name GUIForgeAnimationContainer
extends Control

const CARD_MOVE_TIME := 0.2

@onready var front_card: GUICardFace = %FrontCard
@onready var back_card: GUICardFace = %BackCard
@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton
@onready var card_forging_effect: Node2D = %CardForgingEffect


func play_animation(left_tool_data:ToolData, right_tool_data:ToolData, left_position:Vector2, right_position:Vector2) -> void:
	gui_tool_card_button.hide()
	show()
	front_card.update_with_tool_data(left_tool_data)
	back_card.update_with_tool_data(right_tool_data)
	front_card.global_position = left_position
	back_card.global_position = right_position
	var center_position := (left_position + right_position) / 2
	var tween := Util.create_scaled_tween(self).set_parallel(true)
	tween.tween_property(front_card, "global_position", center_position, CARD_MOVE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(back_card, "global_position", center_position, CARD_MOVE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	front_card.hide()
	back_card.hide()
	card_forging_effect.play_card_forging_effect(front_card, back_card, front_card.size)
