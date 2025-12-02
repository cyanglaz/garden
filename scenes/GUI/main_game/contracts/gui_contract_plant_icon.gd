class_name GUICombatPlaintIcon
extends PanelContainer

var PLANT_ABILITY_ICON_SCENE := load("res://scenes/GUI/main_game/plant_cards/gui_plant_ability_icon.tscn")

@onready var gui_plant_icon: GUIPlantIcon = %GUIPlantIcon
@onready var light_bar: GUISegmentedProgressBar = %LightBar
@onready var water_bar: GUISegmentedProgressBar = %WaterBar
@onready var count_label: Label = %CountLabel
@onready var ability_container: GridContainer = %AbilityContainer

func _ready() -> void:
	light_bar.segment_color = Constants.LIGHT_THEME_COLOR
	water_bar.segment_color = Constants.WATER_THEME_COLOR
	
func update_with_plant_data(plant_data:PlantData, count:int) -> void:
	gui_plant_icon.update_with_plant_data(plant_data)
	light_bar.max_value = plant_data.light
	light_bar.current_value = plant_data.light
	water_bar.max_value = plant_data.water
	water_bar.current_value = plant_data.water
	count_label.text = str(count)
	
	Util.remove_all_children(ability_container)
	for ability_id:String in plant_data.abilities:
		var ability_icon:GUIPlantAbilityIcon = PLANT_ABILITY_ICON_SCENE.instantiate()
		ability_container.add_child(ability_icon)
		ability_icon.update_with_plant_ability_id(ability_id)
