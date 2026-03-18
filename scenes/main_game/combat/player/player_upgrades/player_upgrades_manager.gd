class_name PlayerUpgradesManager
extends RefCounted

signal player_upgrade_activated(player_upgrade:PlayerUpgrade)
signal player_upgrade_stack_updated(id:String, diff:int)

var player_upgrade_containers:Array

func setup(containers:Array) -> void:
	player_upgrade_containers = containers
	for container in player_upgrade_containers:
		container.player_upgrade_activated.connect(func(player_upgrade:PlayerUpgrade): player_upgrade_activated.emit(player_upgrade))
		container.player_upgrade_stack_updated.connect(func(id:String, diff:int): player_upgrade_stack_updated.emit(id, diff))

func handle_prevent_movement_hook() -> bool:
	for container in player_upgrade_containers:
		if container.handle_prevent_movement_hook() == true:
			return true
	return false

func handle_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	for container in player_upgrade_containers:
		await container.handle_tool_application_hook(combat_main, tool_data)	

func handle_card_added_to_hand_hook(tool_datas:Array) -> void:
	for container in player_upgrade_containers:
		await container.handle_card_added_to_hand_hook(tool_datas)

func handle_activation_hook(combat_main:CombatMain) -> void:
	for container in player_upgrade_containers:
		await container.handle_activation_hook(combat_main)

func handle_discard_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	for container in player_upgrade_containers:
		await container.handle_discard_hook(combat_main, tool_datas)

func handle_exhaust_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	for container in player_upgrade_containers:
		await container.handle_exhaust_hook(combat_main, tool_datas)

func handle_draw_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	for container in player_upgrade_containers:
		await container.handle_draw_hook(combat_main, tool_datas)

func handle_stack_update_hook(combat_main:CombatMain, id:String, diff:int) -> void:
	for container in player_upgrade_containers:
		await container.handle_stack_update_hook(combat_main, id, diff)

func _handle_next_stack_update_hook(combat_main:CombatMain, id:String, diff:int) -> void:
	for container in player_upgrade_containers:
		await container.handle_stack_update_hook(combat_main, id, diff)	

func handle_player_move_hook(main_game:CombatMain) -> void:
	for container in player_upgrade_containers:
		await container.handle_player_move_hook(main_game)

func toggle_ui_buttons(on:bool) -> void:
	for container in player_upgrade_containers:
		container.toggle_ui_buttons(on)

func handle_end_turn_hook(combat_main:CombatMain) -> void:
	for container in player_upgrade_containers:
		await container.handle_end_turn_hook(combat_main)

func handle_start_turn_hook(combat_main:CombatMain) -> void:
	for container in player_upgrade_containers:
		await container.handle_start_turn_hook(combat_main)

func handle_hand_size_hook(combat_main: CombatMain) -> int:
	var diff := 0
	for container in player_upgrade_containers:
		diff += await container.handle_hand_size_hook(combat_main)
	return diff
