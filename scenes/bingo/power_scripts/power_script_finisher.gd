class_name PowerScriptFinisher
extends PowerScript

const OVERLAY_SCENE := preload("res://scenes/GUI/game_main/power_overlays/gui_power_place_symbol_overlay.tscn")
const FINISHER_BALL_DATA_PREFIX := "res://data/balls/powers/bingo_ball_the_finisher"

var _weak_power_overlay:WeakRef = weakref(null)

var _activated:bool = false

func activate(game_main:GameMain) -> void:
	var gui_game_main := game_main._gui_game_main
	var power_overlay:GUIPowerPlaceSymbolOverlay = OVERLAY_SCENE.instantiate()
	gui_game_main.add_fullscreen_overlay(power_overlay)
	_weak_power_overlay = weakref(power_overlay)
	power_overlay.bind_gui_bingo_board(gui_game_main.gui_bingo_main._gui_bingo_board)
	power_overlay.activate(game_main._bingo_board)
	var power_level := power_data.level
	var ball_path := FINISHER_BALL_DATA_PREFIX
	if power_level > 0:
		ball_path += str("+", power_level)
	ball_path += ".tres"
	power_overlay.activate_with_ball_path(ball_path)
	power_overlay.deactivated.connect(_on_overlay_deactivated)
	power_overlay.eligible_space_clicked.connect(_on_eligible_space_clicked.bind(game_main))
	_activated = true

func deactivate() -> void:
	assert(_activated, "finisher power should be activated before deactivating")
	_activated = false
	_weak_power_overlay.get_ref().queue_free()
	power_cancelled.emit()

func _on_overlay_deactivated() -> void:
	deactivate()

func _on_eligible_space_clicked(ball_data:BingoBallData, space_index:int, game_main:GameMain) -> void:
	_weak_power_overlay.get_ref().queue_free()
	_activated = false
	game_main._bingo_controller.display_power_symbol_operation_finished.connect(_on_display_power_symbol_finished.bind(game_main._bingo_controller))
	await game_main._bingo_controller.place_power_symbol(ball_data, space_index)

func _on_display_power_symbol_finished(bingo_controller:BingoController) -> void:
	bingo_controller.display_power_symbol_operation_finished.disconnect(_on_display_power_symbol_finished)
	power_deployed.emit()
