class_name EventOptionScriptRemoveCard
extends EventOptionScript

const REMOVE_CARD_MAIN_SCENE: PackedScene = preload("res://scenes/GUI/event/events/remove_card/gui_remove_card_main.tscn")

var _remove_card_main: GUIRemoveCardMain = null

func _run(option_data:EventOptionData, main_game:MainGame) -> Variant:
	_remove_card_main = REMOVE_CARD_MAIN_SCENE.instantiate()
	request_add_sub_scene.emit(_remove_card_main)
	var pool:Array = main_game.card_pool
	_remove_card_main.show_with_pool(pool, Util.get_localized_string("REMOVE_CARD_MAIN_TITLE_TEXT"))
	await _remove_card_main.remove_card_finished
	_remove_card_main.queue_free()
	if option_data.data.has("gold"):
		Events.request_update_gold.emit(-(option_data.data["gold"] as int), true)
	if option_data.data.has("hp"):
		Events.request_hp_update.emit((option_data.data["hp"] as int), ActionData.OperatorType.DECREASE)
	return null

func _should_enable(option_data:EventOptionData, main_game:MainGame) -> bool:
	if option_data.data.has("gold"):
		return main_game.gold >= (option_data.data["gold"] as int)
	elif option_data.data.has("hp"):
		return main_game.hp.value >= (option_data.data["hp"] as int)
	return true
