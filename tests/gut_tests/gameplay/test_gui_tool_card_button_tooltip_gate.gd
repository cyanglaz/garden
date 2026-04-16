extends GutTest

const CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const SPY_SCRIPT := preload("res://tests/gut_tests/gameplay/test_tooltip_spy_tool_card_button.gd")

var _saved_show_card_tooltip: bool


func before_each() -> void:
	_saved_show_card_tooltip = PlayerSettings.setting_data.show_card_tooltip


func after_each() -> void:
	PlayerSettings.update_show_card_tooltip(_saved_show_card_tooltip)


func _make_tool_data() -> ToolData:
	var tool_data := ToolData.new()
	tool_data.id = "tooltip_gate_tool"
	tool_data.energy_cost = 1
	var action := ActionData.new()
	action.action_category = ActionData.ActionCategory.PLAYER
	action.type = ActionData.ActionType.ENERGY
	action.value = 0
	tool_data.actions = [action]
	return tool_data


func _make_card_spy():
	# CombatMain is not added to the tree so @onready scene nodes are not resolved;
	# energy_tracker and other plain fields are still valid for update_with_tool_data.
	var cm := CombatMain.new()
	autofree(cm)
	var td := _make_tool_data()
	var card = CARD_SCENE.instantiate()
	card.set_script(SPY_SCRIPT)
	add_child_autofree(card)
	card.mute_interaction_sounds = true
	card.update_with_tool_data(td, cm)
	card.card_state = GUICardFace.CardState.NORMAL
	card.mouse_in = true
	return card


func test_is_mouse_hover_secondary_tooltip_enabled_false_when_mouse_out() -> void:
	var card := GUIToolCardButton.new()
	autofree(card)
	card.mouse_in = false
	PlayerSettings.setting_data.show_card_tooltip = true
	assert_false(card.is_mouse_hover_secondary_tooltip_enabled())


func test_is_mouse_hover_secondary_tooltip_enabled_false_when_setting_off() -> void:
	var card := GUIToolCardButton.new()
	autofree(card)
	card.mouse_in = true
	PlayerSettings.setting_data.show_card_tooltip = false
	assert_false(card.is_mouse_hover_secondary_tooltip_enabled())


func test_is_mouse_hover_secondary_tooltip_enabled_true_when_both_on() -> void:
	var card := GUIToolCardButton.new()
	autofree(card)
	card.mouse_in = true
	PlayerSettings.setting_data.show_card_tooltip = true
	assert_true(card.is_mouse_hover_secondary_tooltip_enabled())


func test_tooltip_shown_when_setting_enabled() -> void:
	PlayerSettings.setting_data.show_card_tooltip = true
	var card = _make_card_spy()
	await card._on_mouse_entered()
	assert_true(card.tooltip_toggle_calls.has(true))


func test_tooltip_suppressed_when_setting_disabled() -> void:
	PlayerSettings.setting_data.show_card_tooltip = false
	var card = _make_card_spy()
	await card._on_mouse_entered()
	assert_false(card.tooltip_toggle_calls.has(true))
