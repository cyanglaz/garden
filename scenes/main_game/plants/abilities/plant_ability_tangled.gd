class_name PlantAbilityTangled
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _combat_main:CombatMain, _plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.START_TURN

func _trigger_ability_hook(ability_type:Plant.AbilityType, combat_main:CombatMain, _plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.START_TURN)
	var cards_on_hand:Array = combat_main.tool_manager.tool_deck.hand
	if cards_on_hand.is_empty():
		return
	var random_card:ToolData = Util.unweighted_roll(cards_on_hand, 1)[0]
	random_card.turn_energy_modifier += random_card.energy_cost
	combat_main.tool_manager.refresh_ui()
