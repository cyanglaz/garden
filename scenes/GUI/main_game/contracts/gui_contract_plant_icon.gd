class_name GUIContractPlaintIcon
extends PanelContainer

@onready var gui_plant_icon: GUIPlantIcon = %GUIPlantIcon
@onready var light_bar: GUISegmentedProgressBar = %LightBar
@onready var water_bar: GUISegmentedProgressBar = %WaterBar
@onready var count_label: Label = %CountLabel

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
