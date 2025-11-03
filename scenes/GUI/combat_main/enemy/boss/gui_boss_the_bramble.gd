class_name GUIBossTheBramble
extends GUIBoss

func _has_hook(hook_type:HookType) -> bool:
	return hook_type == HookType.LEVEL_START

func _handle_hook(hook_type:HookType) -> void:
	if hook_type != HookType.LEVEL_START:
		return
	await Util.await_for_tiny_time()
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("thorn").get_duplicate()
	var count:int = _boss_data.data["count"] as int
	var starting_position:Vector2 = gui_boss_icon.global_position + Vector2.LEFT * GUIToolCardButton.SIZE.x/2
	var cards:Array[ToolData] = []
	for i in count:
		cards.append(tool_data.get_duplicate())
	await _combat_main.tool_manager.add_tools_to_discard_pile(cards, starting_position, true)
