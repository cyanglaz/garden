class_name ActionController
extends RefCounted

const ACTION_REST := preload("res://data/actions/action_heal.tres")

var _game_main:GameMain: get = _get_game_main
var _weak_game_main:WeakRef
var _action_handling := false

func _init(game_main:GameMain) -> void:
	_weak_game_main = weakref(game_main)

func show_actions() -> void:
	_game_main.animate_show_actions()

func handle_action_selected(action_data:ActionData) -> void:
	if _action_handling:
		return
	_action_handling = true
	if action_data:
		var script := action_data.action_script
		script.action_completed.connect(_on_action_completed.bind(script, action_data))
		script.action_cancelled.connect(_on_action_cancelled.bind(script))
		script.execute(_game_main)

func _get_game_main() -> GameMain:
	return _weak_game_main.get_ref()

func _on_action_completed(script:ActionScript, action_data:ActionData) -> void:
	script.action_completed.disconnect(_on_action_completed.bind(script))
	script.action_cancelled.disconnect(_on_action_cancelled.bind(script))
	_action_handling = false
	_game_main.animate_update_ap(-action_data.cost)

func _on_action_cancelled(script:ActionScript) -> void:
	_action_handling = false
	script.action_completed.disconnect(_on_action_completed.bind(script))
	script.action_cancelled.disconnect(_on_action_cancelled.bind(script))
