class_name PlayerTrinketsContainer
extends PlayerUpgradesContainer

const PLAYER_TRINKET_SCENE_PREFIX := "res://scenes/main_game/combat/player/player_upgrades/trinkets/player_trinket_%s.tscn"

func setup_with_trinket_datas(trinket_datas:Array) -> void:
	for trinket_data:TrinketData in trinket_datas:
		var player_trinket:PlayerTrinket = _get_player_upgrade_scene(trinket_data.id).instantiate()
		player_trinket.data = trinket_data
		add_child(player_trinket)
		player_trinket.request_player_upgrade_hook_animation.connect(func(player_upgrade_id:String): request_player_upgrade_hook_animation.emit(player_upgrade_id))
		player_trinket.request_hook_message_popup.connect(func(player_upgrade_data:ThingData): request_hook_message_popup.emit(player_upgrade_data))

func _get_player_upgrade_scene(id:String) -> PackedScene:
	return load(PLAYER_TRINKET_SCENE_PREFIX % id)

func _get_player_upgrade_data(id:String) -> ThingData:
	return MainDatabase.trinket_database.get_data_by_id(id)
