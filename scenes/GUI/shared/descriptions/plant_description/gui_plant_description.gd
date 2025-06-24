class_name GUIPlantDescription
extends VBoxContainer

@onready var _name_label: Label = %NameLabel
@onready var _light_requirement_label: Label = %LightRequirementLabel
@onready var _water_requirement_label: Label = %WaterRequirementLabel
@onready var _gold_label: Label = %GoldLabel
@onready var _gui_description_rich_text_label: GUIDescriptionRichTextLabel = %GUIDescriptionRichTextLabel

func update_with_plant_data(plant_data:PlantData) -> void:
	_name_label.text = plant_data.display_name
	_light_requirement_label.text = str(plant_data.light)
	_water_requirement_label.text = str(plant_data.water)
	_gold_label.text = str(plant_data.gold)
	_gui_description_rich_text_label.text = plant_data.get_display_description()
