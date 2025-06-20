class_name GUIBenchEnemyContainer
extends VBoxContainer

const GUI_SMALL_ENEMY_BOX_SCENE := preload("res://scenes/GUI/bingo_main/character_boxes/enemy/gui_small_enemy_box.tscn")


func animate_add_bench_enemy(enemy:Enemy) -> void:
	var gui_enemy_box:GUISmallEnemyBox = GUI_SMALL_ENEMY_BOX_SCENE.instantiate()
	add_child(gui_enemy_box)
	gui_enemy_box.bind_character(enemy)
	await gui_enemy_box.animate_appear()

func refresh(enemies:Array[Enemy]) -> void:
	Util.remove_all_children(self)
	for enemy:Enemy in enemies:
		var gui_enemy_box:GUISmallEnemyBox = GUI_SMALL_ENEMY_BOX_SCENE.instantiate()
		add_child(gui_enemy_box)
		gui_enemy_box.bind_character(enemy)
