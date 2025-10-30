class_name WarningManager
extends RefCounted

const GOLD_ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_gold.png"

enum WarningType {
	INSUFFICIENT_ENERGY,
	INSUFFICIENT_GOLD,
	DIALOGUE_THING_DETAIL,
	DIALOGUE_CANNOT_USE_CARD,
	CARD_USE_LIMIT_REACHED,
	CARD_CUSTOM_ERROR,
}

var _gui_energy_tracker:GUIEnergyTracker: get = _get_gui_energy_tracker
var _gui_gold:GUIGold: get = _get_gui_gold
var _gui_dialogue_window:GUIDialogueWindow: get = _get_gui_dialogue_window

var _energy_warning_tooltip_id:String = ""
var _gold_warning_tooltip_id:String = ""
var _weak_main_game:WeakRef = weakref(null)

func _init(main_game:MainGame) -> void:
	_weak_main_game = weakref(main_game)

func show_warning(warning_type:WarningType) -> void:
	match warning_type:
		WarningType.INSUFFICIENT_ENERGY:
			var energy_warning_string := Util.get_localized_string("WARNING_INSUFFICIENT_ENERGY")
			_energy_warning_tooltip_id = Util.get_uuid()
			Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.WARNING, energy_warning_string, _energy_warning_tooltip_id, _gui_energy_tracker, false, GUITooltip.TooltipPosition.TOP, false)
			_gui_energy_tracker.play_insufficient_energy_animation()
		WarningType.INSUFFICIENT_GOLD:
			var gold_icon_string := str("[img=6x6]", GOLD_ICON_PATH, "[/img]")
			var gold_warning_string := Util.get_localized_string("WARNING_INSUFFICIENT_GOLD") % gold_icon_string
			_gold_warning_tooltip_id = Util.get_uuid()
			Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.WARNING, gold_warning_string, _gold_warning_tooltip_id, _gui_gold, false, GUITooltip.TooltipPosition.BOTTOM, false)
		WarningType.DIALOGUE_THING_DETAIL:
			_gui_dialogue_window.show_with_type(GUIDialogueItem.DialogueType.THING_DETAIL)
		WarningType.DIALOGUE_CANNOT_USE_CARD:
			_gui_dialogue_window.show_with_type(GUIDialogueItem.DialogueType.CANNOT_USE_CARD)
		WarningType.CARD_USE_LIMIT_REACHED:
			_gui_dialogue_window.show_with_type(GUIDialogueItem.DialogueType.CARD_USE_LIMIT_REACHED)

func hide_warning(warning_type:WarningType) -> void:
	match warning_type:
		WarningType.INSUFFICIENT_ENERGY:
			Events.request_hide_tooltip.emit(_energy_warning_tooltip_id)
		WarningType.INSUFFICIENT_GOLD:
			Events.request_hide_tooltip.emit(_gold_warning_tooltip_id)
		WarningType.DIALOGUE_THING_DETAIL:
			_gui_dialogue_window.hide_type(GUIDialogueItem.DialogueType.THING_DETAIL)
		WarningType.DIALOGUE_CANNOT_USE_CARD:
			_gui_dialogue_window.hide_type(GUIDialogueItem.DialogueType.CANNOT_USE_CARD)
		WarningType.CARD_USE_LIMIT_REACHED:
			_gui_dialogue_window.hide_type(GUIDialogueItem.DialogueType.CARD_USE_LIMIT_REACHED)

func show_custom_error(message:String, id:String) -> void:
	_gui_dialogue_window.show_custom_error(message, id)

func hide_custom_error(id:String) -> void:
	_gui_dialogue_window.hide_custom_error(id)

func _get_gui_energy_tracker() -> GUIEnergyTracker:
	var combat_main:CombatMain = _weak_main_game.get_ref()._current_scene as CombatMain
	if !combat_main:
		return null
	return combat_main.gui.gui_energy_tracker
				
func _get_gui_gold() -> GUIGold:
	return _weak_main_game.get_ref().gui_main_game.gui_top_bar.gui_gold

func _get_gui_dialogue_window() -> GUIDialogueWindow:
	return _weak_main_game.get_ref().gui_main_game.gui_dialogue_window
