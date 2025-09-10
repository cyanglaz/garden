class_name LevelScriptLadyRose
extends LevelScript

const DELAY := 0.1

func _has_level_start_hook() -> bool:
	return true

func _handle_level_start_hook(main_game:MainGame, icon:GUIEnemy) -> void:
	await Util.await_for_tiny_time()
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("thorn").get_duplicate()
	var count:int = level_data.data["value"] as int
	var starting_position:Vector2 = icon.global_position + Vector2(-GUIToolCardButton.SIZE.x / 2 + icon.size.x / 2, icon.size.y)
	var cards:Array[ToolData] = []
	for i in count:
		cards.append(tool_data.get_duplicate())
	await main_game.tool_manager.add_temp_tools_to_draw_pile(cards, starting_position, true, false)
	level_hook_complicated.emit()
