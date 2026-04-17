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

func handle_pre_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	for container in player_upgrade_containers:
		await container.handle_pre_tool_application_hook(combat_main, tool_data)

func handle_card_added_to_hand_hook(tool_datas:Array, combat_main:CombatMain) -> void:
	for container in player_upgrade_containers:
		await container.handle_card_added_to_hand_hook(tool_datas, combat_main)

func handle_pool_updated_hook(combat_main:CombatMain, pool:Array) -> void:
	for container in player_upgrade_containers:
		await container.handle_pool_updated_hook(combat_main, pool)

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

func queue_end_turn_hooks(combat_main:CombatMain) -> void:
	for container in player_upgrade_containers:
		container.queue_end_turn_hooks(combat_main)

func queue_start_turn_hooks(combat_main:CombatMain) -> void:
	for container in player_upgrade_containers:
		container.queue_start_turn_hooks(combat_main)

func handle_hand_updated_hook(combat_main:CombatMain) -> void:
	for container in player_upgrade_containers:
		await container.handle_hand_updated_hook(combat_main)

func handle_plant_bloom_hook(combat_main:CombatMain) -> void:
	for container in player_upgrade_containers:
		await container.handle_plant_bloom_hook(combat_main)

func handle_damage_taken_hook(combat_main:CombatMain, damage:int) -> void:
	for container in player_upgrade_containers:
		container.handle_damage_taken_hook(combat_main, damage)

func handle_hand_size_hook(combat_main: CombatMain) -> int:
	var diff := 0
	for container in player_upgrade_containers:
		diff += container.handle_hand_size_hook(combat_main)
	return diff

func handle_combat_end_hook(combat_main:CombatMain) -> void:
	for container in player_upgrade_containers:
		await container.handle_combat_end_hook(combat_main)