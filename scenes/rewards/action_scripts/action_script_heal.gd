class_name ActionScriptHeal
extends ActionScript

func execute(game_main:GameMain) -> void:
	game_main._player.animate_restore_hp(_action_data.data["hp"] as int, 0.2, false)
	action_completed.emit()
