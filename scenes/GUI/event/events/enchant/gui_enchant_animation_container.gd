class_name GUIEnchantAnimationContainer
extends Control

signal enchant_card_pressed(card_global_position:Vector2)

const ENCHANT_ICON_MOVE_TIME := 0.2
const FINAL_CARD_SCALE_TIME := 0.2

@onready var gui_card_face: GUICardFace = %GUICardFace
@onready var gui_enchant_icon: GUIEnchantIcon = %GUIEnchantIcon
@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton
@onready var card_enchant_effect: CardEnchantingEffect = %CardEnchantEffect

func play_animation(tool_data:ToolData, enchant_data:EnchantData, tool_global_position:Vector2, enchant_global_position:Vector2, new_tool_data:ToolData) -> void:
	gui_tool_card_button.hide()
	show()
	gui_card_face.update_with_tool_data(tool_data, null)
	gui_card_face.global_position = tool_global_position
	gui_enchant_icon.update_with_enchant_data(enchant_data, null)
	gui_enchant_icon.global_position = enchant_global_position
	var tween := Util.create_scaled_tween(self).set_parallel(true)
	tween.tween_property(gui_enchant_icon, "global_position", tool_global_position + gui_card_face.size / 2, ENCHANT_ICON_MOVE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	gui_card_face.hide()
	gui_enchant_icon.hide()
	await card_enchant_effect.play_card_enchant_effect(tool_global_position + gui_card_face.size / 2)
	gui_tool_card_button.show()
	gui_tool_card_button.update_with_tool_data(new_tool_data, null)
	gui_tool_card_button.global_position = tool_global_position
	gui_tool_card_button.scale = Vector2.ZERO
	gui_tool_card_button.pivot_offset_ratio = Vector2.ONE * 0.5
	var tool_card_button_tween := Util.create_scaled_tween(self)
	tool_card_button_tween.tween_property(gui_tool_card_button, "scale", Vector2.ONE, FINAL_CARD_SCALE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tool_card_button_tween.finished
	gui_tool_card_button.mouse_disabled = false
	gui_tool_card_button.pressed.connect(_on_gui_tool_card_button_pressed)

func _on_gui_tool_card_button_pressed() -> void:
	enchant_card_pressed.emit(gui_tool_card_button.global_position)

func reset() -> void:
	hide()
	gui_tool_card_button.hide()
	gui_card_face.hide()
	gui_enchant_icon.hide()
	if gui_tool_card_button.pressed.is_connected(_on_gui_tool_card_button_pressed):
		gui_tool_card_button.pressed.disconnect(_on_gui_tool_card_button_pressed)
