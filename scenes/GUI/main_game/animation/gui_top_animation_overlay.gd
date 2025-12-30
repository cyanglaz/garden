class_name GUITopAnimationOverlay
extends Control

const ANIMATING_TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const ADD_CARD_TO_PILE_ANIMATION_TIME := 0.5

var _full_deck_button_global_position:Vector2
var _full_deck_button_size:Vector2


func setup(gui_main_game:GUIMainGame) -> void:
	# The button has a margin of 1 on each size internally, so we need to add 2 to the size to get the actual size of the button.
	_full_deck_button_global_position = gui_main_game.gui_top_bar.gui_full_deck_button.global_position - Vector2.ONE
	_full_deck_button_size = gui_main_game.gui_top_bar.gui_full_deck_button.size + Vector2(2, 2)

func animate_add_card_to_deck(from_global_position:Vector2, tool_data:ToolData) -> void:
	var animating_card:GUIToolCardButton = ANIMATING_TOOL_CARD_SCENE.instantiate()
	add_child(animating_card)
	animating_card.update_with_tool_data(tool_data)
	animating_card.global_position = from_global_position
	animating_card.play_discard_sound()
	Util.create_scaled_timer(ADD_CARD_TO_PILE_ANIMATION_TIME * 0.25).timeout.connect(func(): animating_card.animation_mode = true)
	var tween := Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.tween_property(animating_card, "global_position", _full_deck_button_global_position, ADD_CARD_TO_PILE_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(animating_card, "size", _full_deck_button_size, ADD_CARD_TO_PILE_ANIMATION_TIME * 0.75).set_delay(ADD_CARD_TO_PILE_ANIMATION_TIME * 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	animating_card.queue_free()
