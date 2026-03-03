class_name EventScriptWaspMerchant
extends EventScript

func prepare(event_data:EventData, _main_game:MainGame) -> void:
	var card_data:ToolData = MainDatabase.tool_database.roll_tools(1, -1).front()
	var card_id:String = card_data.id
	event_data.data["card"] = card_id

func _prepare(_event_data:EventData, _main_game:MainGame) -> void:
	pass
