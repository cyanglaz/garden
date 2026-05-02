class_name PlantAbilityTangled
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType,  plant:Plant, _combat_main:CombatMain) -> bool:
	return ability_type == Plant.AbilityType.START_TURN && plant.has_player

func _trigger_ability_hook(ability_type:Plant.AbilityType, _plant:Plant, _combat_main:CombatMain) -> void:
	assert(ability_type == Plant.AbilityType.START_TURN)
	Events.request_modify_hand_cards.emit(_update_hand_cards)

func _update_hand_cards(cards:Array) -> void:
	if cards.is_empty():
		return
	var random_card:ToolData = Util.unweighted_roll(cards, 1)[0]
	random_card.turn_energy_modifier += random_card.get_final_energy_cost()
