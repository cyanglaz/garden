class_name EventOptionScriptRemoveCard
extends EventOptionScript

func _run(option_data:EventOptionData, _main_game:MainGame) -> Variant:
	var card_id:String = option_data.data["card"]
	var card_data:ToolData = MainDatabase.tool_database.get_data_by_id(card_id)
	Util.await_for_tiny_time()
	return card_data

func _should_enable(option_data:EventOptionData, main_game:MainGame) -> bool:
	if option_data.data.has("gold"):
		return main_game.gold >= (option_data.data["gold"] as int)
	elif option_data.data.has("hp"):
		return main_game.hp.value >= (option_data.data["hp"] as int)
	return true
