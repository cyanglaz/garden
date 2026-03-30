class_name EventOptionScriptObtainTrinket
extends EventOptionScript

func _run(option_data: EventOptionData, _main_game: MainGame) -> Variant:
	var trinket_id: String = option_data.data["trinket"]
	var trinket_data: TrinketData = MainDatabase.trinket_database.get_data_by_id(trinket_id)
	await Util.await_for_tiny_time()
	return trinket_data

func _prepare(event_data: EventData, _main_game: MainGame, option_data: EventOptionData) -> void:
	option_data.data["trinket"] = event_data.data["trinket"]
