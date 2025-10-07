class_name BossScriptBinder
extends BossScript

func _has_hook(hook_type:HookType) -> bool:
	return hook_type == HookType.LEVEL_START

func _handle_hook(hook_type:HookType, main_game:MainGame) -> void:
	if hook_type != HookType.LEVEL_START:
		return
	await Util.await_for_tiny_time()
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("thorn").get_duplicate()
	var count:int = boss_data.data["count"] as int
	var starting_position:Vector2 = main_game.gui_main_game.get_main_size()/2 - GUIToolCardButton.SIZE/2
	var cards:Array[ToolData] = []
	for i in count:
		cards.append(tool_data.get_duplicate())
	await main_game.tool_manager.add_temp_tools_to_discard_pile(cards, starting_position, true)
