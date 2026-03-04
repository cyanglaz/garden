class_name EventOptionScriptPack
extends EventOptionScript

const REWARD_MAIN_SCENE: PackedScene = preload("res://scenes/GUI/event/events/reward/gui_reward_main.tscn")
var _reward_main: GUIRewardMain = null

func _run(option_data:EventOptionData, _main_game:MainGame) -> Variant:
	_reward_main = REWARD_MAIN_SCENE.instantiate()
	request_add_sub_scene.emit(_reward_main)
	var hp := 0
	var gold := 0
	var pack_type := CombatData.BoosterPackType.COMMON
	if option_data.data.has("hp"):
		hp = option_data.data["hp"] as int
	if option_data.data.has("gold"):
		gold = option_data.data["gold"] as int
	if option_data.data.has("pack_type"):
		var pack_type_string = option_data.data["pack_type"] as String
		match pack_type_string:
			"common":
				pack_type = CombatData.BoosterPackType.COMMON
			"rare":
				pack_type = CombatData.BoosterPackType.RARE
			"legendary":
				pack_type = CombatData.BoosterPackType.LEGENDARY
	_reward_main.show_with_data(gold, hp, pack_type)
	await _reward_main.reward_finished
	_reward_main.queue_free()
	return null
