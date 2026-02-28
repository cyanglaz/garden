class_name GUIForgeAnimationContainer
extends Control

signal forged_card_pressed(card_global_position:Vector2)

const CARD_MOVE_TIME := 0.2

@onready var front_card: GUICardFace = %FrontCard
@onready var back_card: GUICardFace = %BackCard
@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton
@onready var card_forging_effect: Node2D = %CardForgingEffect

func play_animation(left_tool_data:ToolData, right_tool_data:ToolData, left_position:Vector2, right_position:Vector2, forged_tool_data:ToolData) -> void:
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
	await card_forging_effect.play_card_forging_effect(front_card, back_card, front_card.size)
	gui_tool_card_button.show()
	gui_tool_card_button.update_with_tool_data(forged_tool_data)
	gui_tool_card_button.global_position = center_position
	gui_tool_card_button.scale = Vector2.ZERO
	gui_tool_card_button.pivot_offset_ratio = Vector2.ONE * 0.5
	var tool_card_button_tween := Util.create_scaled_tween(self)
	tool_card_button_tween.tween_property(gui_tool_card_button, "scale", Vector2.ONE, CARD_MOVE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tool_card_button_tween.finished
	gui_tool_card_button.mouse_disabled = false
	gui_tool_card_button.pressed.connect(_on_gui_tool_card_button_pressed)

func _on_gui_tool_card_button_pressed() -> void:
	forged_card_pressed.emit(gui_tool_card_button.global_position)
