class_name GUIEnemyContainer
extends Control

@onready var _gui_enemy_box: GUIEnemyBox = %GUIEnemyBox
@onready var _gui_bench_enemy_container: GUIBenchEnemyContainer = %GUIBenchEnemyContainer

func animate_current_enemy_died() -> void:
	await _gui_enemy_box.animate_death()

func animate_spawn_enemy(enemy:Enemy,) -> void:
	_gui_enemy_box.bind_character(enemy)
	await _gui_enemy_box.animate_appear()

func animate_add_bench_enemy(enemy:Enemy) -> void:
	await _gui_bench_enemy_container.animate_add_bench_enemy(enemy)

func clear_warnings() -> void:
	_gui_enemy_box.clear_warnings()
	for enemy_box:GUIEnemyBox in _gui_bench_enemy_container.get_children():
		enemy_box.clear_warnings()

#func animate_spawn_enemy(enemy:Enemy, benched_enemies:Array[Enemy]) -> void:
#	var from_bench := benched_enemies.size() > 0 && benched_enemies[0] == enemy
#	_gui_enemy_box.bind_character(enemy)
#	if from_bench:
#		var first_benched_enemy_gui := _gui_bench_enemy_container.get_child(0) as GUIEnemyBox
#		var from_icon_rect := first_benched_enemy_gui.get_icon_global_rect()
#		first_benched_enemy_gui.hide_all()
#		await _gui_enemy_box.animate_appear_from_bench(from_icon_rect)
#		_gui_bench_enemy_container.refresh(benched_enemies.slice(1, benched_enemies.size()))
#	else:
#		await _gui_enemy_box.animate_appear()