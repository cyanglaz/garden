class_name PlantAttackProjectile
extends Node2D

func attack() -> void:
	var hp_position := Singletons.main_game.gui_main_game.gui_top_bar._gui_player._guihp
	var tween:= Util.create_scaled_tween(self)
	tween.tween_property(self, "global_position", target_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	queue_free()
