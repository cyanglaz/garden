class_name BingoSpaceData
extends Resource

signal ball_data_updated(ball_data:BingoBallData)

var index:int
var ball_data:BingoBallData: set = _set_ball_data, get = _get_ball_data
var bingo_board:BingoBoard: get = _get_bingo_board, set = _set_bingo_board
var gui_bingo_space:GUIBingoSpace: get = _get_gui_bingo_space, set = _set_gui_bingo_space
var ball_script:BingoBallScript: get = _get_ball_script
var space_effect_manager:SpaceEffectManager = SpaceEffectManager.new()

var _ball_data:BingoBallData

var _weak_board:WeakRef = weakref(null)
var _weak_gui_bingo_space:WeakRef = weakref(null)

func copy(other:BingoSpaceData) -> void:
	_weak_board = weakref(other._weak_board.get_ref())
	index = other.index
	if other.ball_data:
		ball_data = other.ball_data.get_duplicate()
	gui_bingo_space = other.gui_bingo_space
	space_effect_manager = other.space_effect_manager.get_duplicate()

func get_duplicate() -> BingoSpaceData:
	var dup:BingoSpaceData = BingoSpaceData.new()
	dup.copy(self)
	return dup

func handle_space_effect_bingo_event(bingo_result:BingoResult) -> void:
	await space_effect_manager.handle_space_effect_bingo_event(self, bingo_result)
	
func generate_attack(target:Character, bingo_result:BingoResult) -> Attack:
	var attack:Attack = null
	if _ball_data:
		attack = Attack.new(target, _ball_data.damage)
		if _ball_data.ball_script:
			_ball_data.ball_script.enhance_attack(bingo_result, attack)
		attack.additional_damage += _ball_data.combat_dmg_boost
	return attack

func force_set_ball_data(val:BingoBallData) -> void:
	if val:
		_ball_data = val
	else:
		_ball_data = null
	if _ball_data:
		if _ball_data.ball_script:
			_ball_data.ball_script.bingo_space_data = self
			_ball_data.ball_script.bingo_board = bingo_board
	ball_data_updated.emit(_ball_data)
	
func is_bingo_blocked_by_space_effect() -> bool:
	var space_effect_blocking := false
	for space_effect:SpaceEffect in space_effect_manager.space_effects:
		if space_effect.block_bingo():
			space_effect_blocking = true
			break
	return space_effect_blocking

#region getter/setter

func _set_ball_data(val:BingoBallData) -> void:
	if _ball_data && val && _ball_data.id == val.id:
		return
	force_set_ball_data(val)

func _get_ball_data() -> BingoBallData:
	return _ball_data

func _get_bingo_board() -> BingoBoard:
	return _weak_board.get_ref()

func _get_gui_bingo_space() -> GUIBingoSpace:
	return _weak_gui_bingo_space.get_ref()

func _set_bingo_board(val:BingoBoard) -> void:
	_weak_board = weakref(val)

func _set_gui_bingo_space(val:GUIBingoSpace) -> void:
	_weak_gui_bingo_space = weakref(val)

func _get_ball_script() -> BingoBallScript:
	if !_ball_data:
		return null
	return _ball_data.ball_script
#endregion
