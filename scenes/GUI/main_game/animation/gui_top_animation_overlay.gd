class_name GUITopAnimationOverlay
extends Control

const ANIMATING_TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const ANIMATING_TRINKET_SCENE := preload("res://scenes/GUI/combat_main/trinkets/gui_player_trinket.tscn")
const ADD_CARD_TO_PILE_ANIMATION_TIME := 0.5
const ADD_TRINKET_ANIMATION_TIME := 0.5

var _full_deck_button_global_position:Vector2
var _full_deck_button_size:Vector2
var _trinket_button_global_position:Vector2
var _trinket_button_size:Vector2


func setup(gui_main_game:GUIMainGame) -> void:
	# The button has a margin of 1 on each size internally, so we need to add 2 to the size to get the actual size of the button.
	_full_deck_button_global_position = gui_main_game.gui_top_bar.gui_full_deck_button.global_position - Vector2.ONE
	_full_deck_button_size = gui_main_game.gui_top_bar.gui_full_deck_button.size + Vector2(2, 2)
	_trinket_button_global_position = gui_main_game.gui_top_bar.gui_trinket_button.global_position - Vector2.ONE
	_trinket_button_size = gui_main_game.gui_top_bar.gui_trinket_button.size + Vector2(2, 2)

func animate_add_card_to_deck(from_global_position:Vector2, tool_data:ToolData) -> void:
	var animating_card:GUIToolCardButton = ANIMATING_TOOL_CARD_SCENE.instantiate()
	add_child(animating_card)
	animating_card.update_with_tool_data(tool_data, null)
	animating_card.global_position = from_global_position
	animating_card.play_discard_sound()
	Util.create_scaled_timer(ADD_CARD_TO_PILE_ANIMATION_TIME * 0.25).timeout.connect(func(): animating_card.animation_mode = true)
	var tween := Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.tween_property(animating_card, "global_position", _full_deck_button_global_position, ADD_CARD_TO_PILE_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(animating_card, "size", _full_deck_button_size, ADD_CARD_TO_PILE_ANIMATION_TIME * 0.75).set_delay(ADD_CARD_TO_PILE_ANIMATION_TIME * 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	animating_card.queue_free()

func animate_add_trinket_to_collection(from_global_position:Vector2, trinket_data:TrinketData, scale_factor:float) -> void:
	var animating_trinket:GUIPlayerTrinket = ANIMATING_TRINKET_SCENE.instantiate()
	add_child(animating_trinket)
	animating_trinket.play_collect_sound()
	animating_trinket.update_with_trinket_data(trinket_data)
	animating_trinket.global_position = from_global_position
	var initial_size := animating_trinket.size * scale_factor
	var default_size := animating_trinket.size
	var trinket_button_center := _trinket_button_global_position + _trinket_button_size / 2
	var target_position := trinket_button_center - default_size / 2
	animating_trinket.size = initial_size
	var tween := Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.tween_property(animating_trinket, "global_position", target_position, ADD_TRINKET_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(animating_trinket, "size", default_size, ADD_TRINKET_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	animating_trinket.queue_free()
