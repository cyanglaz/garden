class_name GUIPlantAbilityIconContainer
extends VBoxContainer

var PLANT_ABILITY_ICON_SCENE := load("res://scenes/GUI/main_game/plant_cards/gui_plant_ability_icon.tscn")

func setup_with_plant(plant:Plant) -> void:
	Util.remove_all_children(self)
	for plant_ability_data:PlantAbilityData in plant.data.abilities:
		var ability_icon:GUIPlantAbilityIcon = PLANT_ABILITY_ICON_SCENE.instantiate()
		if plant_ability_data.active_before_bloom:
			ability_icon.active = true
		else:
			ability_icon.active = false
		add_child(ability_icon)
		ability_icon.update_with_plant_ability_data(plant_ability_data)
	
	plant.plant_ability_container.request_ability_hook_animation.connect(_on_ability_hook_animation_requested)

func activate_abilities() -> void:
	for ability_icon:GUIPlantAbilityIcon in get_children():
		ability_icon.active = true

func remove_all() -> void:
	Util.remove_all_children(self)

func _on_ability_hook_animation_requested(ability_id:String) -> void:
	var animating_icon:GUIPlantAbilityIcon
	for ability_icon:GUIPlantAbilityIcon in get_children():
		if ability_icon.ability_id == ability_id:
			animating_icon = ability_icon
	assert(animating_icon !=null, "Animating icon not found")
	animating_icon.play_trigger_animation()
