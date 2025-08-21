class_name GUIPlantDescription
extends VBoxContainer

@onready var _name_label: Label = %NameLabel
@onready var _light_requirement_label: Label = %LightRequirementLabel
@onready var _water_requirement_label: Label = %WaterRequirementLabel
@onready var _point_label: Label = %PointLabel
@onready var _rich_text_label: RichTextLabel = %RichTextLabel

func update_with_plant_data(plant_data:PlantData) -> void:
	_name_label.text = plant_data.display_name
	_light_requirement_label.text = str(plant_data.light)
	_water_requirement_label.text = str(plant_data.water)
	_point_label.text = str(plant_data.points)
	_rich_text_label.text = plant_data.get_display_description()
