class_name EventOptionScriptObtainCard
extends EventOptionScript

func _run(option_data:EventOptionData) -> void:
	var max_hp_value := option_data.data["max_hp"] as int
	if max_hp_value > 0:
		Events.request_max_hp_update.emit(max_hp_value, ActionData.OperatorType.INCREASE)
	else:
		Events.request_max_hp_update.emit(max_hp_value, ActionData.OperatorType.DECREASE)
	if option_data.data.has("gold"):
		Events.request_update_gold.emit(-(option_data.data["gold"] as int), true)
	await Util.await_for_tiny_time()

func _should_enable(option_data:EventOptionData, main_game:MainGame) -> bool:
	return true
