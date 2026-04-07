class_name EventOptionScriptPack
extends EventOptionScript

const CARDS_REWARD_MAIN: PackedScene = preload("res://scenes/GUI/event/events/reward/gui_reward_cards_main.tscn")

func _run(option_data:EventOptionData, _main_game:MainGame) -> Variant:
	var cards_reward_main: GUIRewardCardsMain = CARDS_REWARD_MAIN.instantiate()
	request_add_sub_scene.emit(cards_reward_main)
	var pack_type := CombatData.BoosterPackType.COMMON
	if option_data.data.has("pack_type"):
		var pack_type_string = option_data.data["pack_type"] as String
		match pack_type_string:
			"common":
				pack_type = CombatData.BoosterPackType.COMMON
			"rare":
				pack_type = CombatData.BoosterPackType.RARE
			"legendary":
				pack_type = CombatData.BoosterPackType.LEGENDARY
	cards_reward_main.spawn_cards_with_pack_type(pack_type, Vector2.ZERO)
	await cards_reward_main.reward_finished
	cards_reward_main.queue_free()
	return null
