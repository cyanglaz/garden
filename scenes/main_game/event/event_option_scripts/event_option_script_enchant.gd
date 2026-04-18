class_name EventOptionScriptEnchant
extends EventOptionScript

const ENCHANT_MAIN_SCENE: PackedScene = preload("res://scenes/GUI/event/events/enchant/gui_enchant_main.tscn")
signal _enchant_finished()
var _enchant_main: GUIEnchantMain = null

func _run(_option_data:EventOptionData, _main_game:MainGame) -> Variant:
	_enchant_main = ENCHANT_MAIN_SCENE.instantiate()
	_enchant_main.setup_with_card_pool(_main_game.card_pool)
	_enchant_main.enchant_finished.connect(_on_enchant_finished)
	_enchant_main.enchant_card_pressed.connect(_on_enchant_card_pressed)
	request_add_sub_scene.emit(_enchant_main)
	await _enchant_finished
	return null

func _should_enable(option_data:EventOptionData, main_game:MainGame) -> bool:
	if option_data.data.has("gold"):
		return main_game.gold >= (option_data.data["gold"] as int)
	elif option_data.data.has("hp"):
		return main_game.hp.value >= (option_data.data["hp"] as int)
	return true

func _on_enchant_finished(_tool_data:ToolData, front_card_data:ToolData, back_card_data:ToolData) -> void:
	Events.request_remove_card_from_deck.emit(front_card_data)
	Events.request_remove_card_from_deck.emit(back_card_data)

func _on_enchant_card_pressed(tool_data:ToolData, enchant_card_global_position:Vector2) -> void:
	Events.request_add_card_to_deck.emit(tool_data, enchant_card_global_position)
	await Util.await_for_tiny_time()
	_enchant_finished.emit()
	_enchant_main.queue_free()
