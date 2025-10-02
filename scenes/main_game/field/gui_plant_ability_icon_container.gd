class_name GUIPlantAbilityIconContainer
extends VBoxContainer

const PLANT_ABILITY_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_ability_icon.tscn")

func setup_with_plant_ability_container(plant_ability_container:PlantAbilityContainer) -> void:
	Util.remove_all_children(self)
	for ability_node:PlantAbility in plant_ability_container.get_children():
		var ability_icon:GUIPlantAbilityIcon = PLANT_ABILITY_ICON_SCENE.instantiate()
		add_child(ability_icon)
		ability_icon.update_with_plant_ability_id(ability_node.ability_data.id)
	
	plant_ability_container.request_ability_hook_animation.connect(_on_ability_hook_animation_requested)

func remove_all() -> void:
	Util.remove_all_children(self)

func _on_ability_hook_animation_requested(ability_id:String) -> void:
	var animating_icon:GUIPlantAbilityIcon
	for ability_icon:GUIPlantAbilityIcon in get_children():
		if ability_icon.ability_id == ability_id:
			animating_icon = ability_icon
	assert(animating_icon !=null, "Animating icon not found")
	animating_icon.play_trigger_animation()
