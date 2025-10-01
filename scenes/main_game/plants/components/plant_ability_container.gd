class_name PlantAbilityContainer
extends Node2D

var abilities:Array[PlantAbilityData]

func setup_with_plant_data(plant_data:PlantData) -> void:
	for ability_id:String in plant_data.abilities:
		var ability_data:PlantAbilityData = MainDatabase.plant_ability_database.get_data_by_id(ability_id)
		var ability_node:PlantAbility = ability_data.get_ability()
		assert(ability_node)
		add_child(ability_node)
