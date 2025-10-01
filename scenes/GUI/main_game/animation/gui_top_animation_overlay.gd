class_name GUITopAnimationOverlay
extends Control

const ANIMATING_TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const ADD_CARD_TO_PILE_ANIMATION_TIME := 0.5

var _full_deck_button:GUIDeckButton: get = _get_full_deck_button
var _weak_full_deck_button:WeakRef = weakref(null)


func setup(gui_main_game:GUIMainGame) -> void:
	_weak_full_deck_button = weakref(gui_main_game.gui_top_bar.gui_full_deck_button)

func animate_add_card_to_deck(from_global_position:Vector2, tool_data:ToolData) -> void:
	var animating_card:GUIToolCardButton = ANIMATING_TOOL_CARD_SCENE.instantiate()
	add_child(animating_card)
	animating_card.update_with_tool_data(tool_data)
	animating_card.global_position = from_global_position
	animating_card.play_move_sound()
	Util.create_scaled_timer(ADD_CARD_TO_PILE_ANIMATION_TIME * 0.25).timeout.connect(func(): animating_card.animation_mode = true)
	var tween := Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.tween_property(animating_card, "global_position", _full_deck_button.global_position, ADD_CARD_TO_PILE_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(animating_card, "size", _full_deck_button.size, ADD_CARD_TO_PILE_ANIMATION_TIME * 0.75).set_delay(ADD_CARD_TO_PILE_ANIMATION_TIME * 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	animating_card.queue_free()

func _get_full_deck_button() -> GUIDeckButton:
	return _weak_full_deck_button.get_ref()
