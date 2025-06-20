class_name GameMain
extends Node2D

const NEW_BOARD_DELAY := 0.5
const PLAYER_MAX_HP := 100
const ENEMY_PLAYER_TURN_DELAY := 0.2
const BINGO_MAIN_SHOW_DELAY := 0.2
const AP_PER_WIN_NORMAL := 2
const AP_PER_WIN_BOSS := 4


#signal _player_draw_ended()
#signal _enemy_turn_ended()
signal _power_cd_increased()

@export var test_enemy_data:CharacterData
@export var player_data:CharacterData

@onready var _gui_game_main: GUIGameMain = %GUIGameMain
@onready var _battle_music: AudioStreamPlayer2D = %BattleMusic

var session_seed:int
var enemy_controller:EnemyController
var _bingo_board:BingoBoard = BingoBoard.new()
var _player:Player
var _bingo_controller:BingoController
var _current_level:int = -1
var _action_controller:ActionController
var _new_card_controller:NewCardController
var _draw_count:int = 0
var _drawing := false
var _weak_selected_power_data:WeakRef = weakref(null)

func _ready() -> void:
	session_seed = _get_new_seed()
	seed(session_seed)
	print("new game session started with seed: ", session_seed)
	
	#randomize()
	Singletons.game_main = self
	_player = Player.new(player_data)
	_player.hurt.connect(_on_player_hurt)
	enemy_controller = EnemyController.new()
	add_child(enemy_controller, false, Node.INTERNAL_MODE_BACK)
	enemy_controller.bind_enemy_container(_gui_game_main.gui_bingo_main._gui_enemy_container)
	#enemy_controller.bind_gui_enemy_process(_gui_game_main.gui_main_top_bar.gui_enemy_process)
	#setup _gui_game_main
	_gui_game_main.bind_game_main(self)
	_gui_game_main.bind_enemy_controller(enemy_controller)
	_gui_game_main.draw_button_evoked.connect(_on_draw_button_evoked)
	_gui_game_main.action_selected.connect(_on_action_selected)
	_gui_game_main.action_selection_finished.connect(_on_action_selection_finished)
	_gui_game_main.new_card_selected.connect(_on_new_card_selected)
	_gui_game_main.power_symbol_placed.connect(_on_power_symbol_placed)
	_gui_game_main.power_button_evoked.connect(_on_power_button_evoked)

	#setup bingo controller
	_bingo_controller = BingoController.new(_bingo_board, _gui_game_main.gui_bingo_main, _player , enemy_controller)
	_bingo_controller.draw_sequence_finished.connect(_on_draw_sequence_finished)
	_bingo_controller.player_died.connect(_on_player_died)	
	_bingo_controller.enemy_died.connect(_on_enemy_died)
	add_child(_bingo_controller, false, Node.INTERNAL_MODE_BACK)
	#_bingo_controller.signal_player_died.connect(_on_player_died)

	#setup action controller
	_action_controller = ActionController.new(self)

	#setup new card controller
	_new_card_controller = NewCardController.new(self)

	#self signals
	#_player_draw_ended.connect(_on_player_draw_ended)
	#_enemy_turn_ended.connect(_on_enemy_turn_ended)
	_power_cd_increased.connect(_on_power_cd_increased)

	_gui_game_main.toggle_buttons(false)
	await _setup_bingo_board()
	_show_bingo_main()
	start_new_level()
	await _start_new_combat()
	
	# Test
	#await enemy_controller.handle_draw()
	#await enemy_controller.handle_draw()
	#await _branch_enemy_died([])

	#_gui_game_main.animate_show_demo_end_container()	
	#_player.action_point = 5
	#animate_show_actions()

func start_new_level() -> void:
	_current_level = 0
	_player.draw_box.refresh()
	enemy_controller.populate_enemies(0)

func add_view_to_top_container(control:Control) -> void:
	_gui_game_main.add_view_to_top_container(control)
#region main uis

func animate_show_upgrade_main(new_cards:Array[BingoBallData]) -> void:
	await _gui_game_main.animate_show_upgrade_main(new_cards)

func animate_show_actions() -> void:
	await _gui_game_main.animate_show_actions()

func animate_update_ap(diff:int) -> void:
	_player.action_point += diff
	await _gui_game_main.animate_update_ap(_player.action_point)

#endregion

#region private

func _setup_bingo_board() -> void:
	_bingo_board.generate()
	await _gui_game_main.refresh_with_board(_bingo_board, false)

func _spawn_next_enemy() -> void:
	await enemy_controller.spawn_enemy(test_enemy_data)

func _show_bingo_main() -> void:
	@warning_ignore("redundant_await")
	await _gui_game_main.show_bingo_main()

func _is_auto_draw_enabled() -> bool:
	return _gui_game_main.gui_bingo_main.auto_draw

func _get_new_seed() -> int:
	randomize()
	var random_seed = randi()
	return random_seed

#endregion

#region combat sequence

func _start_new_combat() -> void:
	_gui_game_main.toggle_buttons(false)
	_gui_game_main.update_level(_current_level)
	_bingo_controller.reset_new_combat()
	_player.status_effect_manager.clear_status_effects()
	_player.power_manager.reset_all_cd_counters()
	_gui_game_main.gui_bingo_main.update_power_cd()
	await _spawn_next_enemy()
	enemy_controller.reset_all_active_enemies()
	await Util.create_scaled_timer(BINGO_MAIN_SHOW_DELAY).timeout
	if !_battle_music.playing:
		_battle_music.play()
	if _is_auto_draw_enabled():
		_on_draw_button_evoked()
	_show_card_reward_scene()

func _show_card_reward_scene() -> void:
	_new_card_controller.show_new_cards(_current_level)

func _on_new_card_selected(bingo_ball_data:BingoBallData) -> void:
	if bingo_ball_data:
		@warning_ignore("redundant_await")
		await _new_card_controller.handle_new_card_selected(bingo_ball_data)
	await _show_bingo_main()
	_gui_game_main.toggle_buttons(true)
	await _bingo_controller.shuffle()
	_drawing = false

func _on_draw_button_evoked() -> void:
	if _drawing:
		return
	_gui_game_main.toggle_buttons(false)
	_drawing = true
	_start_draw()

func _start_draw() -> void:
	#var script_path = ProjectSettings.globalize_path("res://scripts/bounce.applescript")
	#OS.execute("osascript", [script_path])
	_draw_count += 1
	_bingo_controller.start_draw()

func _on_draw_sequence_finished() -> void:
	_handle_power_cd_gain()
	_power_cd_increased.emit()

func _handle_power_cd_gain() -> void:
	_player.power_manager.update_cd_counter(1)
	_gui_game_main.gui_bingo_main.update_power_cd()

func _on_player_died() -> void:
	_gui_game_main.animate_show_game_over_container()

func _on_enemy_died() -> void:
	await _bingo_controller.discard_balls()
	_gui_game_main.toggle_buttons(false)
	# Show enemy death animation
	var enemy_type:EnemyData.Type = enemy_controller.get_current_enemy().data.type
	# Increase action points when enemy is dead
	match enemy_type:
		EnemyData.Type.NORMAL:
			await animate_update_ap(AP_PER_WIN_NORMAL)
		EnemyData.Type.BOSS:
			await animate_update_ap(AP_PER_WIN_BOSS)
			_gui_game_main.animate_show_demo_end_container()	
			_current_level += 1
			return
	await enemy_controller.handle_enemy_died()
	await Util.create_scaled_timer(0.4).timeout
	_handle_action_selection()

func _on_power_cd_increased() -> void:
	_end_draw()

func _end_draw() -> void:
	_drawing = false
	_gui_game_main.toggle_buttons(true)
	if _is_auto_draw_enabled():
		_on_draw_button_evoked()

func _on_power_button_evoked(power_data:PowerData) -> void:
	_gui_game_main.toggle_buttons(false)
	if _weak_selected_power_data.get_ref():
		var is_selected_power:bool = _weak_selected_power_data.get_ref() == power_data
		_weak_selected_power_data.get_ref().power_script.deactivate()
		if is_selected_power:
			# If selecting the same power, we deactivate the power and do not activate it again.
			return
	_weak_selected_power_data = weakref(power_data)
	power_data.power_script.activate(self)
	power_data.power_script.power_deployed.connect(_on_power_deployed.bind(power_data))
	power_data.power_script.power_cancelled.connect(_on_power_cancelled.bind(power_data))

func _on_power_symbol_placed(power_data:BingoBallData, space_index:int) -> void:
	await _bingo_controller.place_power_symbol(power_data, space_index)

func _on_power_deployed(power_data:PowerData) -> void:
	power_data.cd_counter = 0
	_gui_game_main.gui_bingo_main.handle_power_update()
	_on_power_cancelled(power_data)

func _on_power_cancelled(power_data:PowerData) -> void:
	_weak_selected_power_data = weakref(null)
	power_data.power_script.power_deployed.disconnect(_on_power_deployed)
	power_data.power_script.power_cancelled.disconnect(_on_power_cancelled)
	_gui_game_main.toggle_buttons(true)

func _handle_action_selection() -> void:
	_action_controller.show_actions()

func _on_action_selected(action_data:ActionData) -> void:
	_action_controller.handle_action_selected(action_data)

func _on_action_selection_finished() -> void:
	await _show_bingo_main()
	await _start_new_combat()
	
#endregion

#region events

func _on_player_hurt(damage:Damage) -> void:
	if _player.hp.value > 0:
		_bingo_controller.handle_all_ball_for_player_lose_hp_event(damage)
	
#endregion


#func _handle_energy_gain() -> void:
#	var energy_gain := 1
#	_player.energy.restore(energy_gain)
#	await Util.create_scaled_timer(0.1).timeout
#	if _player.energy.is_full:
#		await _gui_game_main.play_energy_full_animation()
#		_player.energy.value = 0
#		_new_card_controller.show_new_cards(_current_level)
#		# branch to _on_new_card_selected
#	else:
#		_power_cd_increased.emit()

#func _on_new_card_selected(bingo_ball_data:BingoBallData) -> void:
#	if bingo_ball_data:
#		@warning_ignore("redundant_await")
#		await _new_card_controller.handle_new_card_selected(bingo_ball_data)
#	await _show_bingo_main()
#	_power_cd_increased.emit()
