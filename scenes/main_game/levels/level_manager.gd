class_name LevelManager
extends RefCounted

const GUI_ENEMY_SCENE := preload("res://scenes/GUI/main_game/characters/gui_enemy.tscn")
const GUI_ENEMY_MOVE_TIME := 0.5

const LEVEL_PER_CHAPTER := 4
const BASE_POINTS := 15

var levels:Array[LevelData]
var level:int = -1
var day_manager:DayManager = DayManager.new()

func next_level() -> void:
	level += 1

func next_day() -> void:
	day_manager.next_day()

func get_day() -> int:
	return day_manager.day

func is_boss_level() -> bool:
	return (level + 1) % LEVEL_PER_CHAPTER == 0

func get_day_left() -> int:
	return day_manager.get_day_left()

func generate_with_chapter(chapter:int) -> void:
	levels.clear()
	levels = MainDatabase.level_database.roll_levels(LEVEL_PER_CHAPTER, chapter)

func apply_level_actions(main_game:MainGame, level_data:LevelData, hook_type:LevelScript.HookType) -> void:
	if level_data.type != LevelData.Type.BOSS:
		return
	await _animate_level_icon_move(main_game, levels[level])

func _animate_level_icon_move(main_game:MainGame, level_data:LevelData) -> void:
	var gui_enemy := GUI_ENEMY_SCENE.instantiate()
	Singletons.main_game.add_control_to_overlay(gui_enemy)
	gui_enemy.global_position = main_game.gui_main_game.gui_enemy.global_position
	gui_enemy.update_with_level_data(level_data)
	gui_enemy.play_flying_sound()
	var tween:Tween = Util.create_scaled_tween(gui_enemy)
	var game_container := Singletons.main_game.gui_main_game.game_container
	var target_position:Vector2 = game_container.global_position + Vector2(game_container.size.x/2, 0)
	print(target_position)
	tween.tween_property(
		gui_enemy,
		"global_position",
		target_position,	
		GUI_ENEMY_MOVE_TIME
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	gui_enemy.queue_free()
