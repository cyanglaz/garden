extends GutTest

const CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const SPY_SCRIPT := preload("res://tests/gut_tests/gameplay/test_hover_spy_tool_card_button.gd")


func _make_card():
	# Instantiate the full scene so @onready card_face is populated before
	# _ready() runs, then swap in the spy script that stubs _is_mouse_over_card().
	var card = CARD_SCENE.instantiate()
	card.set_script(SPY_SCRIPT)
	add_child_autofree(card)
	card.mute_interaction_sounds = true
	return card


func test_refresh_emits_entered_on_transition_to_hovered() -> void:
	var card = _make_card()
	watch_signals(card)
	card.stub_mouse_over = true
	card._refresh_card_hover_state()
	assert_signal_emit_count(card, "mouse_entered_card", 1)
	assert_signal_emit_count(card, "mouse_exited_card", 0)


func test_refresh_emits_exited_on_transition_to_not_hovered() -> void:
	var card = _make_card()
	card._card_hovered = true
	watch_signals(card)
	card._refresh_card_hover_state()
	assert_signal_emit_count(card, "mouse_exited_card", 1)
	assert_signal_emit_count(card, "mouse_entered_card", 0)


func test_refresh_does_not_reemit_when_state_unchanged() -> void:
	var card = _make_card()
	card.stub_mouse_over = true
	card._refresh_card_hover_state()
	watch_signals(card)
	card._refresh_card_hover_state()
	card._refresh_card_hover_state()
	assert_signal_emit_count(card, "mouse_entered_card", 0)
	assert_signal_emit_count(card, "mouse_exited_card", 0)


func test_refresh_full_cycle_emits_once_each() -> void:
	var card = _make_card()
	watch_signals(card)
	card.stub_mouse_over = true
	card._refresh_card_hover_state()
	card._refresh_card_hover_state()
	card.stub_mouse_over = false
	card._refresh_card_hover_state()
	card._refresh_card_hover_state()
	assert_signal_emit_count(card, "mouse_entered_card", 1)
	assert_signal_emit_count(card, "mouse_exited_card", 1)
