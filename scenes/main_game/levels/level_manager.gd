class_name LevelManager
extends RefCounted

const GUI_ENEMY_SCENE := preload("res://scenes/GUI/main_game/characters/gui_enemy.tscn")
const GUI_ENEMY_MOVE_TIME := 0.8

const LEVEL_PER_CHAPTER := 4
const BASE_POINTS := 15
const LEVEL_ICON_MOVE_Y_OFFSET := 20

var levels:Array[LevelData]
var level_index:int = -1
var day_manager:DayManager = DayManager.new()
var current_level:LevelData
var _weak_gui_enemy:WeakRef = weakref(null)

func next_level() -> void:
	level_index += 1
	current_level = levels[level_index]

func next_day() -> void:
	day_manager.next_day()

func get_day() -> int:
	return day_manager.day

func is_boss_level() -> bool:
	return (level_index + 1) % LEVEL_PER_CHAPTER == 0

func get_day_left() -> int:
	return day_manager.get_day_left()

func generate_with_chapter(chapter:int) -> void:
	levels.clear()
	levels = MainDatabase.level_database.roll_levels(LEVEL_PER_CHAPTER, chapter)

func apply_level_actions(main_game:MainGame, hook_type:LevelScript.HookType) -> void:
	if current_level.type != LevelData.Type.BOSS:
		return
	match hook_type:
		LevelScript.HookType.LEVEL_START:
			if current_level.level_script.has_level_start_hook():
				await _animate_level_icon_move(main_game, current_level)
				await current_level.level_script.handle_level_start_hook(main_game, _weak_gui_enemy.get_ref())	
		LevelScript.HookType.TURN_START:
			if current_level.level_script.has_turn_start_hook():
				await _animate_level_icon_move(main_game, current_level)
				await current_level.level_script.handle_turn_start_hook(main_game, _weak_gui_enemy.get_ref())
	_remove_icon()
	
func _animate_level_icon_move(main_game:MainGame, level_data:LevelData) -> void:
	var gui_enemy := GUI_ENEMY_SCENE.instantiate()
	_weak_gui_enemy = weakref(gui_enemy)
	Singletons.main_game.add_control_to_overlay(gui_enemy)
	gui_enemy.global_position = main_game.gui_main_game.gui_enemy.global_position
	gui_enemy.update_with_level_data(level_data)
	gui_enemy.play_flying_sound()
	gui_enemy.display_mode = true
	var tween:Tween = Util.create_scaled_tween(gui_enemy)
	var game_container := Singletons.main_game.gui_main_game.game_container
	var target_position:Vector2 = game_container.global_position + Vector2(game_container.size.x/2 - gui_enemy.size.x/2, LEVEL_ICON_MOVE_Y_OFFSET)
	tween.tween_property(
		gui_enemy,
		"global_position",
		target_position,	
		GUI_ENEMY_MOVE_TIME
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func _remove_icon() -> void:
	assert(_weak_gui_enemy.get_ref())
	_weak_gui_enemy.get_ref().queue_free()
	_weak_gui_enemy = weakref(null)
