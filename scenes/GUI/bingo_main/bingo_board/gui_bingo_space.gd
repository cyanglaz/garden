class_name GUIBingoSpace
extends PanelContainer

const GUI_SPACE_EFFECT_SCENE := preload("res://scenes/GUI/bingo_main/bingo_board/gui_space_effect.tscn")

const DEFAULT_COLOR := Constants.COLOR_BEIGE_3
const BINGO_BLINK_REGION_POSITION := Vector2(0, 22)

const SCORE_ANIMATION_PAUSE := 0.2
const SCORE_ANIMATION_OFFSET := 2
const SKILL_ANIMATION_OFFSET := 6
const REMOVAL_ANIMATION_TIME := 0.4
const MOVE_ANIMATION_TIME := 0.2

signal trigger_animation_finished()
signal remove_animation_finished()
signal refresh_finished()
signal move_animation_finished()

@onready var _gui_symbol: GUISymbol = %GUISymbol
@onready var _background: NinePatchRect = %Background
@onready var _display_audio_player: AudioStreamPlayer2D = %DisplayAudioPlayer
@onready var _bingo_audio_player: AudioStreamPlayer2D = %BingoAudioPlayer
@onready var _skill_audio_player: AudioStreamPlayer2D = %SkillAudioPlayer
@onready var _power_up_audio_player: AudioStreamPlayer2D = %PowerUpAudioPlayer
@onready var _removal_audio_player: AudioStreamPlayer2D = %RemovalAudioPlayer
@onready var _move_audio_player: AudioStreamPlayer2D = %MoveAudioPlayer
@onready var _space_effect_container: VBoxContainer = %SpaceEffectContainer
@onready var _debug_label: Label = %DebugLabel

var highlight := false: set = _set_highlight

var _gui_bingo_board:GUIBingoBoard: get = _get_gui_bingo_board, set = _set_gui_bingo_board
var _space_data:BingoSpaceData: set = _set_space_data, get = _get_space_data

var _weak_gui_bingo_board:WeakRef = weakref(null)
var _weak_space_data:WeakRef = weakref(null)

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("ui_debug_bingo_space"):
		_debug_label.visible = !_debug_label.visible

func refresh_with_data(bingo_space:BingoSpaceData, animated:bool = true, animation_time:float = REMOVAL_ANIMATION_TIME) -> void:
	_space_data = bingo_space
	_space_data.gui_bingo_space = self
	if animated && !bingo_space.ball_data:
		await animate_removal(false, animation_time)
	display_symbol(bingo_space.ball_data, false)
	_on_space_effect_updated(bingo_space.space_effect_manager.space_effects)
	refresh_finished.emit()
	_debug_label.text = str(bingo_space.index)
	_debug_label.hide()

func animate_removal(with_audio:bool = true, time:float = REMOVAL_ANIMATION_TIME) -> void:
	if with_audio:
		_removal_audio_player.play()
	assert(_space_data.ball_data == null, "ball data must be null before playing removal animation")
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(_gui_symbol, "scale", Vector2.ZERO, time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	await tween.finished
	_gui_symbol.hide()
	_background.region_rect.position = Util.get_bingo_ball_background_region(null, highlight)
	_gui_symbol.scale = Vector2.ONE
	remove_animation_finished.emit()

func animate_move_to_space(animation_container:Control, target_index:int, time:float = MOVE_ANIMATION_TIME) -> void:
	_move_audio_player.play()
	assert(_space_data.ball_data)
	var target_space := _gui_bingo_board.get_space(target_index)
	var target_position:Vector2 = target_space.get_global_position()
	var animating_gui_symbol:GUISymbol = Util.get_copied_ui_symbol(_gui_symbol)
	#animating_gui_symbol.z_index = 5
	animation_container.add_child(animating_gui_symbol)
	animating_gui_symbol.bind_ball_data(_space_data.ball_data)
	animating_gui_symbol.global_position = _gui_symbol.global_position
	_gui_symbol.hide()
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(animating_gui_symbol, "global_position", target_position, time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	animating_gui_symbol.queue_free()
	move_animation_finished.emit()
	_gui_symbol.show()

func animate_attack(animation_container:Control, has_power_up:bool, target_position:Vector2, time:float) -> void:
	var animating_gui_symbol:GUISymbol = Util.get_copied_ui_symbol(_gui_symbol)
	animation_container.add_child(animating_gui_symbol)
	animating_gui_symbol.bind_ball_data(_space_data.ball_data)
	animating_gui_symbol.global_position = _gui_symbol.global_position
	_gui_symbol.hide()
	if has_power_up:
		await _animate_power_up(animating_gui_symbol, time)
	#animating_gui_symbol.z_index = 5
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(animating_gui_symbol, "global_position", target_position, time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	await tween.finished
	animating_gui_symbol.queue_free()
	_gui_symbol.show()


func animate_trigger(time:float) -> void:
	#animating_gui_symbol.z_index = 5
	var original_position:Vector2 = _gui_symbol.position
	_skill_audio_player.play()
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 2:
		tween.tween_property(_gui_symbol, "position", _gui_symbol.position + Vector2.UP * SKILL_ANIMATION_OFFSET, time/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(_gui_symbol, "position", original_position, time/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	trigger_animation_finished.emit()

func animate_bingo(time:float) -> void:
	_bingo_audio_player.play()
	var original_rect_position := _background.region_rect.position
	for i in 3:
		_background.region_rect.position = BINGO_BLINK_REGION_POSITION
		await Util.create_scaled_timer(time/6).timeout
		_background.region_rect.position = original_rect_position
		await Util.create_scaled_timer(time/6).timeout

func display_symbol(bingo_ball_data:BingoBallData, with_audio:bool = true) -> void:
	if with_audio:
		_display_audio_player.play()
	_gui_symbol.bind_ball_data(bingo_ball_data)
	_background.region_rect.position = Util.get_bingo_ball_background_region(bingo_ball_data, highlight)
	_gui_symbol.show()

func _animate_power_up(animating_gui_symbol:GUISymbol, time:float) -> void:
	_gui_symbol.hide()
	#animating_gui_symbol.z_index = 5
	_power_up_audio_player.play()
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(animating_gui_symbol, "scale", Vector2.ONE * 1.2, time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(time)
	await tween.finished

#region getter/setter

func _get_gui_bingo_board() -> GUIBingoBoard:
	return _weak_gui_bingo_board.get_ref()

func _set_gui_bingo_board(val:GUIBingoBoard) -> void:
	_weak_gui_bingo_board = weakref(val)

func _get_space_data() -> BingoSpaceData:
	return _weak_space_data.get_ref()

func _set_space_data(val:BingoSpaceData) -> void:
	if _weak_space_data.get_ref() != val:
		val.space_effect_manager.space_effect_updated.connect(_on_space_effect_updated)
	_weak_space_data = weakref(val)

func _set_highlight(val:bool) -> void:
	highlight = val
	_background.region_rect.position = Util.get_bingo_ball_background_region(_space_data.ball_data, highlight)

#endregion

#region events

func _on_space_effect_updated(space_effects:Array[SpaceEffect]) -> void:
	Util.remove_all_children(_space_effect_container)
	for space_effect:SpaceEffect in space_effects:
		var gui_space_effect:GUISpaceEffect = GUI_SPACE_EFFECT_SCENE.instantiate()
		_space_effect_container.add_child(gui_space_effect)
		gui_space_effect.bind_with_space_effect(space_effect)

#endregion
