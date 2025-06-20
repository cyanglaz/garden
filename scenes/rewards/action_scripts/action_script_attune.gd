class_name ActionScriptAttune
extends ActionScript

func execute(game_main:GameMain) -> void:
	var player := game_main._player
	var un_upgraded_balls:Array[BingoBallData] = player.draw_box.pool.filter(func(ball:BingoBallData):return !ball.is_plus)
	game_main._gui_game_main.gui_overlay_main._gui_attune_main.attune_completed.connect(_on_attune_completed.bind(game_main))
	game_main._gui_game_main.gui_overlay_main._gui_attune_main.attune_canceled.connect(_on_attune_canceled.bind(game_main))
	game_main._gui_game_main.gui_overlay_main.animate_show_attune_main(un_upgraded_balls)

func _on_attune_completed(game_main:GameMain) -> void:
	game_main._gui_game_main.gui_overlay_main._gui_attune_main.attune_completed.disconnect(_on_attune_completed.bind(game_main))
	game_main._gui_game_main.gui_overlay_main._gui_attune_main.attune_canceled.disconnect(_on_attune_canceled.bind(game_main))
	action_completed.emit()

func _on_attune_canceled(game_main:GameMain) -> void:
	game_main._gui_game_main.gui_overlay_main._gui_attune_main.attune_completed.disconnect(_on_attune_completed.bind(game_main))
	game_main._gui_game_main.gui_overlay_main._gui_attune_main.attune_canceled.disconnect(_on_attune_canceled.bind(game_main))
	action_cancelled.emit()
