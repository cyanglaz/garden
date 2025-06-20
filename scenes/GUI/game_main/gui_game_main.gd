class_name GUIGameMain
extends CanvasLayer

signal new_card_selected(bingo_ball_data:BingoBallData)
signal action_selected(action_data:ActionData)
signal action_selection_finished()
signal draw_button_evoked()
signal power_symbol_placed(power_data:BingoBallData, space_index:int)
signal power_button_evoked(power_data:PowerData)

@onready var gui_main_top_bar: GUIMainTopBar = %GUIMainTopBar
@onready var gui_bingo_main: GUIBingoMain = %GUIBingoMain
@onready var gui_overlay_main: GUIOverlayMain = %GUIOverlayMain
@onready var _gui_game_over_main: GUIGameOverMain = %GUIGameOverMain
@onready var _gui_demo_end_main: GUIDemoEndMain = %GUIDemoEndMain
@onready var _gui_settings_main: GUISettingsMain = %GUISettingsMain
@onready var _top_level_overlays: Control = %TopLevelOverlays

func bind_game_main(game_main:GameMain) -> void:
	gui_main_top_bar.bind_main(game_main)
	gui_bingo_main.bind_player(game_main._player)
	gui_overlay_main.bind_game_main(game_main)
	gui_bingo_main.draw_button_evoked.connect(func(): draw_button_evoked.emit())
	gui_bingo_main.power_symbol_placed.connect(func(power_data:BingoBallData, space_index:int):power_symbol_placed.emit(power_data, space_index))
	gui_bingo_main.power_button_evoked.connect(func(power_data:PowerData):power_button_evoked.emit(power_data))
	gui_overlay_main.new_ball_selected.connect(func(bingo_ball_data:BingoBallData):new_card_selected.emit(bingo_ball_data))
	gui_overlay_main.action_selected.connect(func(action_data:ActionData):action_selected.emit(action_data))
	gui_overlay_main.action_selection_finished.connect(func():action_selection_finished.emit())
	gui_main_top_bar.all_deck_button_evoked.connect(_on_all_deck_button_evoked.bind(game_main))
	gui_main_top_bar.setting_button_evoked.connect(_on_setting_button_evoked)
	gui_main_top_bar.board_view_button_evoked.connect(_on_board_view_button_evoked)

func add_fullscreen_overlay(control:Control) -> void:
	_top_level_overlays.add_child(control)

func add_view_to_top_container(control:Control) -> void:
	gui_overlay_main.add_child_to_top_view(control)

func update_level(level:int) -> void:
	gui_main_top_bar.update_level(level)

func bind_enemy_controller(enemy_spawner:EnemyController) -> void:
	gui_main_top_bar._bind_enemy_controller(enemy_spawner)

func toggle_buttons(enabled:bool) -> void:
	gui_bingo_main.toggle_buttons(enabled)

#region show/hide main uis

func show_bingo_main() -> void:
	gui_bingo_main.animate_show()

func animate_show_upgrade_main(new_cards:Array[BingoBallData]) -> void:
	@warning_ignore("redundant_await")
	await gui_overlay_main.animate_show_upgrade_main(new_cards)

func animate_show_actions() -> void:
	@warning_ignore("redundant_await")
	await gui_overlay_main.animate_show_actions()
#endregion

#region show/hide secondary uis

func animate_show_attune_main(un_upgraded_balls:Array[BingoBallData]) -> void:
	@warning_ignore("redundant_await")
	await gui_overlay_main.animate_show_attune_main(un_upgraded_balls)

func animate_show_forge_main(balls:Array[BingoBallData]) -> void:
	@warning_ignore("redundant_await")
	await gui_overlay_main.animate_show_forge_main(balls)

func animate_show_demo_end_container() -> void:
	_gui_demo_end_main.animate_show()

func animate_show_game_over_container() -> void:
	_gui_game_over_main.animate_show()

#endregion

#region top bar

func animate_update_ap(ap:int) -> void:
	await gui_main_top_bar.animate_update_ap(ap)

#endregion

#region bingo main

func refresh_with_board(bingo_board:BingoBoard, animated:bool = false) -> void:
	await gui_bingo_main.refresh_with_board(bingo_board, animated)

func refresh_spaces_for_bingo(bingo_board:BingoBoard, bingo_results:Array[BingoResult]) -> void:
	await gui_bingo_main.refresh_spaces_for_bingo(bingo_board, bingo_results)

func animate_spawn_enemy(enemy:Enemy, from_bench:bool) -> void:
	await gui_bingo_main.animate_spawn_enemy(enemy, from_bench)

func animate_add_bench_enemy(enemy:Enemy) -> void:
	await gui_bingo_main.animate_add_bench_enemy(enemy)

#endregion

#region events

func _on_all_deck_button_evoked(game_main:GameMain) -> void:
	gui_overlay_main.toggle_all_deck_display(game_main._player.draw_box.pool)
	
func _on_setting_button_evoked() -> void:
	if _gui_settings_main.visible:
		_gui_settings_main.animate_hide()
	else:
		_gui_settings_main.animate_show()

func _on_board_view_button_evoked() -> void:
	gui_overlay_main.toggle_bingo_board_view()
#endregion
