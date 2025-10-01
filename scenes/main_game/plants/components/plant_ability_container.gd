class_name PlantAbilityContainer
extends Node2D

var abilities:Array[PlantAbilityData]

func setup_with_plant_data(plant_data:PlantData) -> void:
	for ability_id:String in plant_data.abilities:
		var ability_data:PlantAbilityData = MainDatabase.plant_ability_database.get_data_by_id(ability_id)
		var ability_node:PlantAbility = ability_data.get_ability()
		abilities.append(ability_node)
		assert(ability_node)
		add_child(ability_node)

func trigger_ability(ability_type:Plant.AbilityType, main_game:MainGame, plant:Plant) -> void:
	for ability_node:PlantAbility in get_children():
		if ability_node.has_ability_hook(ability_type):
			await ability_node.trigger_ability_hook(ability_type, main_game, plant)

func _notification(what:int) -> void:
	if what == NOTIFICATION_PREDELETE:
		abilities.clear()