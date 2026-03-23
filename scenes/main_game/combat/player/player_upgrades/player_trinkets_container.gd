class_name PlayerTrinketsContainer
extends PlayerUpgradesContainer

const PLAYER_TRINKET_SCENE_PREFIX := "res://scenes/main_game/combat/player/player_upgrades/trinkets/player_trinket_%s.tscn"

func handle_tool_application_hook(combat_main: CombatMain, tool_data: ToolData) -> void:
	await super.handle_tool_application_hook(combat_main, tool_data)
	player_upgrades_updated.emit()

func setup_with_trinket_datas(trinket_datas:Array) -> void:
	for trinket_data:TrinketData in trinket_datas:
		var player_trinket:PlayerTrinket = _get_player_upgrade_scene(trinket_data.id).instantiate()
		player_trinket.data = trinket_data
		add_child(player_trinket)

func _get_player_upgrade_scene(id:String) -> PackedScene:
	return load(PLAYER_TRINKET_SCENE_PREFIX % id)

func _get_player_upgrade_data(id:String) -> ThingData:
	return MainDatabase.trinket_database.get_data_by_id(id)
