class_name PlayerStatusContainer
extends PlayerUpgradesContainer

const PLAYER_STATUS_SCENE_PREFIX := "res://scenes/main_game/combat/player/player_upgrades/player_status/player_status_%s.tscn"

func clear_status_on_turn_end() -> void:
	for player_status:PlayerStatus in get_all_player_upgrades():
		if player_status.data.reduce_stack_on_turn_end:
			player_status.stack -= 1
			if player_status.stack <= 0:
				_remove_player_upgrade(player_status)
		if player_status.data.single_turn:
			_remove_player_upgrade(player_status)
	player_upgrades_updated.emit()

func clear_single_turn_player_upgrades() -> void:
	for player_upgrade:PlayerUpgrade in get_all_player_upgrades():
		if player_upgrade.data.single_turn:
			_remove_player_upgrade(player_upgrade)
	player_upgrades_updated.emit()

func _get_player_upgrade_scene(id:String) -> PackedScene:
	return load(PLAYER_STATUS_SCENE_PREFIX % id)

func _get_player_upgrade_data(id:String) -> ThingData:
	return MainDatabase.player_status_database.get_data_by_id(id)
