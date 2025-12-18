class_name GUIPlantDescription
extends VBoxContainer

const PLANT_ABILITY_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_ability_icon.tscn")

@onready var _name_label: Label = %NameLabel
@onready var _light_requirement_label: Label = %LightRequirementLabel
@onready var _water_requirement_label: Label = %WaterRequirementLabel
@onready var _ability_container: GridContainer = %AbilityContainer

func update_with_plant_data(plant_data:PlantData) -> void:
	_name_label.text = plant_data.get_display_name()
	_name_label.add_theme_color_override("font_color", Util.get_plant_name_color(plant_data))
	_light_requirement_label.text = str(plant_data.light)
	_water_requirement_label.text = str(plant_data.water)
	
	Util.remove_all_children(_ability_container)
	if plant_data.abilities.size() > 0:
		_ability_container.show()
		for plant_ability_id:String in plant_data.abilities.keys():
			var plant_ability_stack:int = (plant_data.abilities[plant_ability_id] as int)
			var ability_icon:GUIPlantAbilityIcon = PLANT_ABILITY_ICON_SCENE.instantiate()
			_ability_container.add_child(ability_icon)
			var plant_ability_data:PlantAbilityData = MainDatabase.plant_ability_database.get_data_by_id(plant_ability_id)
			ability_icon.update_with_plant_ability_data(plant_ability_data, plant_ability_stack)
	else:
		_ability_container.hide()
	
