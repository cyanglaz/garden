class_name ActionScriptForge
extends ActionScript

func execute(game_main:GameMain) -> void:
	var player := game_main._player
	var un_upgraded_balls:Array[BingoBallData] = player.draw_box.pool.filter(func(ball:BingoBallData):return !ball.is_plus)
	game_main._gui_game_main.gui_overlay_main._gui_forge_main.forge_completed.connect(_on_forge_completed.bind(game_main))
	game_main._gui_game_main.gui_overlay_main._gui_forge_main.forge_canceled.connect(_on_forge_canceled.bind(game_main))
	game_main._gui_game_main.gui_overlay_main.animate_show_forge_main(un_upgraded_balls)

func _on_forge_completed(game_main:GameMain) -> void:
	game_main._gui_game_main.gui_overlay_main._gui_forge_main.forge_completed.disconnect(_on_forge_completed.bind(game_main))
	game_main._gui_game_main.gui_overlay_main._gui_forge_main.forge_canceled.disconnect(_on_forge_canceled.bind(game_main))
	action_completed.emit()

func _on_forge_canceled(game_main:GameMain) -> void:
	game_main._gui_game_main.gui_overlay_main._gui_forge_main.forge_completed.disconnect(_on_forge_completed.bind(game_main))
	game_main._gui_game_main.gui_overlay_main._gui_forge_main.forge_canceled.disconnect(_on_forge_canceled.bind(game_main))
	action_cancelled.emit()
