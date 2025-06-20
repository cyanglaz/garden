class_name BingoBallScript
extends RefCounted

enum EventTriggerType {
	PLACEMENT,
	DRAW,
	PLAYER_LOST_HP,
	BINGO,
	OTHER_SYMBOL_PLACEMENT,
	ALL_BINGO
}

const TRIGGER_ANIMATION_TIME := 0.3

@warning_ignore("unused_signal")
signal _all_bingo_event_finished()

signal _draw_event_finished()
signal _placed_on_board_event_finished()
signal _self_bingo_event_finished()
signal _other_symbol_replacement_event_finished()

var bingo_space_data:BingoSpaceData: get = _get_bingo_space_data, set = _set_bingo_space_data
var bingo_board:BingoBoard: get = _get_bingo_board, set = _set_bingo_board
var target_character:Character: get = _get_target_character

var _draws:int = 0
@warning_ignore("unused_private_class_variable")
var _bingo_ball_data:BingoBallData: get = _get_bingo_ball_data, set = _set_bingo_ball_data
var _weak_board:WeakRef = weakref(null)
var _weak_bingo_space_data:WeakRef = weakref(null)
var _weak_bingo_ball_data:WeakRef = weakref(null)
var _weak_bingo_result:WeakRef = weakref(null)

func _init(bingo_ball_data:BingoBallData) -> void:
	_weak_bingo_ball_data = weakref(bingo_ball_data)

# Triggered when any bingo'd occurs, does not have to include this space.
func handle_all_bingo(bingo_result:BingoResult) -> void:
	if has_all_bingo_events(bingo_result):
		bingo_space_data.gui_bingo_space.trigger_animation_finished.connect(_on_trigger_animation_finished.bind(bingo_space_data.gui_bingo_space, EventTriggerType.ALL_BINGO))
		bingo_space_data.gui_bingo_space.animate_trigger(TRIGGER_ANIMATION_TIME)
		await _all_bingo_event_finished
	
func enhance_attack(_bingo_result:BingoResult, attack:Attack) -> void:
	_enhance_attack(_bingo_result, attack)

func handle_placed_on_board() -> void:
	if _has_placement_events():
		bingo_space_data.gui_bingo_space.trigger_animation_finished.connect(_on_trigger_animation_finished.bind(bingo_space_data.gui_bingo_space, EventTriggerType.PLACEMENT))
		bingo_space_data.gui_bingo_space.animate_trigger(TRIGGER_ANIMATION_TIME)
		await _placed_on_board_event_finished

func animate_handle_draw() -> void:
	_draws += 1
	if _has_draw_events(_draws):
		bingo_space_data.gui_bingo_space.trigger_animation_finished.connect(_on_trigger_animation_finished.bind(bingo_space_data.gui_bingo_space, EventTriggerType.DRAW))
		bingo_space_data.gui_bingo_space.animate_trigger(TRIGGER_ANIMATION_TIME)
		await _draw_event_finished
	
func handle_player_lost_hp(damage:Damage) -> void:
	_handle_player_lost_hp(damage)

func handle_self_bingo_events(bingo_result:BingoResult) -> void:
	_weak_bingo_result = weakref(bingo_result)
	if _has_self_bingo_events(bingo_result):
		if _has_self_bingo_event_trigger_animation():
				bingo_space_data.gui_bingo_space.trigger_animation_finished.connect(_on_trigger_animation_finished.bind(bingo_space_data.gui_bingo_space, EventTriggerType.BINGO))
				bingo_space_data.gui_bingo_space.animate_trigger(TRIGGER_ANIMATION_TIME)
				await _self_bingo_event_finished
		elif _has_async_self_bingo_events():
			_handle_self_bingo_events(bingo_result)
			await _self_bingo_event_finished
		else:
			_handle_self_bingo_events(bingo_result)

func handle_other_symbol_replacement(displayed_space:BingoSpaceData) -> void:
	assert(displayed_space.index != bingo_space_data.index)
	if _has_other_symbol_placement_events(displayed_space):
		bingo_space_data.gui_bingo_space.trigger_animation_finished.connect(_on_trigger_animation_finished.bind(bingo_space_data.gui_bingo_space, EventTriggerType.OTHER_SYMBOL_PLACEMENT))
		bingo_space_data.gui_bingo_space.animate_trigger(TRIGGER_ANIMATION_TIME)
		await _other_symbol_replacement_event_finished
	
# This has to be sync to avoid complication of move balls flow.
func handle_removed_from_board() -> void:
	_handle_removed_from_board()

func evaluate_for_description() -> void:
	pass

#region events check

func has_power_up(bingo_result:BingoResult) -> bool:
	return _has_power_up(bingo_result)

func has_all_bingo_events(_bingo_result:BingoResult) -> bool:
	return false

func _has_other_symbol_placement_events(_displayed_space:BingoSpaceData) -> bool:
	return false

func _has_placement_events() -> bool:
	return false

func _has_draw_events(__draws:int) -> bool:
	return false

func _has_self_bingo_events(_bingo_result:BingoResult) -> bool:
	return false

func _has_self_bingo_event_trigger_animation() -> bool:
	return false

func _has_async_self_bingo_events() -> bool:
	return false

func _has_power_up(_bingo_result:BingoResult) -> bool:
	return false



#endregion

#region handle events

func _handle_self_bingo_events(_bingo_result:BingoResult) -> void:
	pass

func _handle_player_lost_hp(_damage:Damage) -> void:
	pass

func _enhance_attack(_bingo_result:BingoResult, _attack:Attack) -> void:
	pass

func _handle_removed_from_board() -> void:
	pass

func _handle_all_bingo_events() -> void:
	pass

func _handle_draw_events() -> void:
	pass

func _handle_placement_events() -> void:
	pass

func _handle_other_symbol_replacement_events() -> void:
	pass

#region getter/setter

func _get_bingo_board() -> BingoBoard:
	return _weak_board.get_ref()

func _set_bingo_board(val:BingoBoard) -> void:
	_weak_board = weakref(val)

func _get_bingo_space_data() -> BingoSpaceData:
	return _weak_bingo_space_data.get_ref()

func _set_bingo_space_data(val:BingoSpaceData) -> void:
	_weak_bingo_space_data = weakref(val)

func _get_bingo_ball_data() -> BingoBallData:
	return _weak_bingo_ball_data.get_ref()

func _set_bingo_ball_data(val:BingoBallData) -> void:
	_weak_bingo_ball_data = weakref(val)

func _get_target_character() -> Character:
	match _bingo_ball_data.team:
		BingoBallData.Team.PLAYER:
			return Singletons.game_main.enemy_controller.get_current_enemy()
		BingoBallData.Team.ENEMY:
			return Singletons.game_main._player
	return null

#endregion

#region events

func _on_trigger_animation_finished(gui_bingo_space:GUIBingoSpace, _event_trigger_type:EventTriggerType) -> void:
	gui_bingo_space.trigger_animation_finished.disconnect(_on_trigger_animation_finished.bind(gui_bingo_space))
	match _event_trigger_type:
		EventTriggerType.BINGO:
			_handle_self_bingo_events(_weak_bingo_result.get_ref())
		EventTriggerType.ALL_BINGO:
			_handle_all_bingo_events()
		EventTriggerType.DRAW:
			_handle_draw_events()
		EventTriggerType.PLACEMENT:
			_handle_placement_events()
		EventTriggerType.OTHER_SYMBOL_PLACEMENT:
			_handle_other_symbol_replacement_events()
			
#endregion
