class_name GUIPlantDescription
extends VBoxContainer

@onready var _name_label: Label = %NameLabel
@onready var _light_requirement_label: Label = %LightRequirementLabel
@onready var _water_requirement_label: Label = %WaterRequirementLabel

func update_with_plant_data(plant_data:PlantData) -> void:
	_name_label.text = plant_data.display_name
	_name_label.add_theme_color_override("font_color", Util.get_plant_name_color(plant_data))
	_light_requirement_label.text = str(plant_data.light)
	_water_requirement_label.text = str(plant_data.water)
	if plant_data.immune_to_status.size() > 0:
		var status_texts := ""
		for status_id in plant_data.immune_to_status:
			status_texts += "{field_status:" + status_id + "}" + ", "
		status_texts = status_texts.trim_suffix(", ")
		var status_description := Util.get_localized_string("IMMUNE_TO_STATUS_TEXT") % status_texts
		status_description = DescriptionParser.format_references(status_description, {}, {}, func(_reference_id:String) -> bool: return false)
		
