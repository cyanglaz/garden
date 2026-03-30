class_name EventOptionScriptBind
extends EventOptionScript

const BIND_MAIN_SCENE: PackedScene = preload("res://scenes/GUI/event/events/bind/gui_bind_main.tscn")
signal _bind_finished()
var _bind_main: GUIBindMain = null

func _run(_option_data:EventOptionData, _main_game:MainGame) -> Variant:
	_bind_main = BIND_MAIN_SCENE.instantiate()
	_bind_main.setup_with_card_pool(_main_game.card_pool)
	_bind_main.bind_finished.connect(_on_bind_finished)
	_bind_main.bind_card_pressed.connect(_on_bind_card_pressed)
	request_add_sub_scene.emit(_bind_main)
	await _bind_finished
	return null

func _should_enable(option_data:EventOptionData, main_game:MainGame) -> bool:
	if option_data.data.has("gold"):
		return main_game.gold >= (option_data.data["gold"] as int)
	elif option_data.data.has("hp"):
		return main_game.hp.value >= (option_data.data["hp"] as int)
	return true

func _on_bind_finished(_tool_data:ToolData, front_card_data:ToolData, back_card_data:ToolData) -> void:
	var front_to_remove: ToolData = front_card_data
	if front_card_data.front_card != null:
		front_to_remove = front_card_data.front_card

	var back_to_remove: ToolData = back_card_data
	if back_card_data.front_card != null:
		back_to_remove = back_card_data.front_card

	Events.request_remove_card_from_deck.emit(front_to_remove)
	Events.request_remove_card_from_deck.emit(back_to_remove)
func _on_bind_card_pressed(tool_data:ToolData, bind_card_global_position:Vector2) -> void:
	Events.request_add_card_to_deck.emit(tool_data, bind_card_global_position)
	await Util.await_for_tiny_time()
	_bind_finished.emit()
	_bind_main.queue_free()
