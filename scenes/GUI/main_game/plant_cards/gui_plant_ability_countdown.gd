class_name GUIPlantAbilityCountdown
extends PanelContainer

const COUNT_DOWN_DOT_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_ability_countdown_dot.tscn")

@onready var h_box_container: HBoxContainer = %HBoxContainer

func setup_with_plant_ability(plant_ability:PlantAbility) -> void:
	Util.remove_all_children(h_box_container)
	if plant_ability.ability_data.cooldown <= 0:
		hide()
		return
	for i in plant_ability.ability_data.cooldown:
		var count_down_dot:GUIPlantAbilityCountdownDot = COUNT_DOWN_DOT_SCENE.instantiate()
		h_box_container.add_child(count_down_dot)
		count_down_dot.hide()
	plant_ability.cooldown_updated.connect(_on_cooldown_updated)
	_on_cooldown_updated(plant_ability.current_cooldown)

func _on_cooldown_updated(cooldown:int) -> void:
	for i in h_box_container.get_child_count():
		if i < cooldown:
			h_box_container.get_child(i).show()
		else:
			h_box_container.get_child(i).hide()
