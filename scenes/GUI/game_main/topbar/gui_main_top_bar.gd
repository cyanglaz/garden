class_name GUIMainTopBar
extends Control

signal setting_button_evoked()
signal board_view_button_evoked()
signal all_deck_button_evoked()

@onready var gui_enemy_process: GUIEnemyProcess = %GUIEnemyProcess
@onready var _gui_top_bar_player: GUITopBarPlayer = %GUITopBarPlayer
@onready var _level_label: Label = %LevelLabel
@onready var _gui_action_points: GUIActionPoints = %GUIActionPoints
@onready var _gui_all_deck_button: GUIDeckButton = %GUIAllDeckButton
@onready var _gui_enemy_forecast_bar: GUIEnemyForecastBar = %GUIEnemyForecastBar
@onready var _gui_settings_button: GUISettingsButton = %GUISettingsButton
@onready var _gui_board_view_button: GUITextureButton = %GUIBoardViewButton

func bind_main(game_main:GameMain) -> void:
	_gui_top_bar_player.bind_player(game_main._player)
	update_level(game_main._current_level)
	_gui_all_deck_button.bind_draw_box(game_main._player.draw_box)
	_gui_all_deck_button.action_evoked.connect(func() -> void: all_deck_button_evoked.emit())
	_gui_board_view_button.action_evoked.connect(func() -> void: board_view_button_evoked.emit())
	_gui_settings_button.action_evoked.connect(_on_settings_button_evoked)
	_gui_action_points.set_static_ap(game_main._player.action_point)

func update_level(level:int) -> void:
	_level_label.text = "level: " + str(level + 1)

func _bind_enemy_controller(enemy_spawner:EnemyController) -> void:
	_gui_enemy_forecast_bar.bind_enemy_controller(enemy_spawner)

func animate_update_ap(ap:int) -> void:
	await _gui_action_points.animate_update_ap(ap)

func _on_settings_button_evoked() -> void:
	setting_button_evoked.emit()
