class_name GUIToolCardAnimationController
extends RefCounted

const ANIMATING_TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const DRAW_ANIMATION_TIME := 0.2
const DRAW_ANIMATION_DELAY := 0.1

func animate_draw(draw_results:Array[ToolData], gui_main_game:GUIMainGame) -> void:
	if draw_results.is_empty():
		return
	var total_card_count := gui_main_game.gui_tool_card_container.get_card_count() + draw_results.size()
	var card_positions:Array[Vector2] = gui_main_game.gui_tool_card_container.calculate_positions(total_card_count)
	var starting_index := gui_main_game.gui_tool_card_container.get_card_count()
	var tween:Tween = Util.create_scaled_tween(gui_main_game)
	tween.set_parallel(true)
	var animating_cards:Array[GUIToolCardButton] = []
	for i in total_card_count:
		var animating_card:GUIToolCardButton
		if i < starting_index:
			animating_card = gui_main_game.gui_tool_card_container.get_card(i)
		else:
			animating_card = ANIMATING_TOOL_CARD_SCENE.instantiate()
			gui_main_game.add_control_to_overlay(animating_card)
			animating_card.hide()
			var initial_scale := 0.4
			var tool_data:ToolData = draw_results[i - starting_index]
			animating_card.global_position = gui_main_game.gui_draw_box_button.global_position + gui_main_game.gui_draw_box_button.size/2 - animating_card.size/2*initial_scale
			animating_card.scale = Vector2.ONE * initial_scale
			animating_card.update_with_tool_data(tool_data)
			animating_cards.append(animating_card)
		var tool_data:ToolData = null
		var delay_index := i - starting_index + 1
		if delay_index >= 0:
			Util.create_scaled_timer(DRAW_ANIMATION_DELAY * delay_index).timeout.connect(func(): animating_card.play_move_sound())
		var card_local_position:Vector2 = card_positions[i]
		var target_global_position:Vector2 = gui_main_game.gui_tool_card_container.global_position + card_local_position
		tween.tween_property(animating_card, "visible", true, 0.01).set_delay(DRAW_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(animating_card, "global_position", target_global_position, DRAW_ANIMATION_TIME).set_delay(DRAW_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(animating_card, "scale", Vector2.ONE, DRAW_ANIMATION_TIME).set_delay(DRAW_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	for animating_card in animating_cards:
		animating_card.queue_free()
