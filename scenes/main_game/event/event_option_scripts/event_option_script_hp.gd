class_name EventOptionScriptHP
extends EventOptionScript

func _run(option_data:EventOptionData) -> void:
	var hp_value := option_data.data["hp"] as int
	if hp_value > 0:
		Events.request_hp_update.emit(hp_value, ActionData.OperatorType.INCREASE)
	else:
		Events.request_hp_update.emit(hp_value, ActionData.OperatorType.DECREASE)
	if option_data.data.has("gold"):
		Events.request_update_gold.emit(-(option_data.data["gold"] as int), true)
	await Util.await_for_tiny_time()

func _should_enable(option_data:EventOptionData, main_game:MainGame) -> bool:
	if !option_data.data.has("gold"):
		return true
	var gold_value := option_data.data["gold"] as int
	return main_game.gold >= gold_value
