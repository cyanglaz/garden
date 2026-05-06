class_name EventOptionScriptObtainCard
extends EventOptionScript

func _run(option_data:EventOptionData, _main_game:MainGame) -> Variant:
	var card_id:String = option_data.data["card"]
	var card_data:ToolData = MainDatabase.tool_database.get_data_by_id(card_id)
	if option_data.data.has("gold"):
		Events.request_update_gold.emit(-(option_data.data["gold"] as int), true)
	if option_data.data.has("hp"):
		Events.request_hp_update.emit((option_data.data["hp"] as int), ActionData.OperatorType.DECREASE)
	Util.await_for_tiny_time()
	return card_data

func _should_enable(option_data:EventOptionData, main_game:MainGame) -> bool:
	if option_data.data.has("gold"):
		return main_game.gold >= (option_data.data["gold"] as int)
	elif option_data.data.has("hp"):
		return main_game.hp.value >= (option_data.data["hp"] as int)
	return true

func _prepare(event_data:EventData, _main_game:MainGame, option_data:EventOptionData) -> void:
	var card_id:String = event_data.data["card"]
	option_data.data["card"] = card_id
