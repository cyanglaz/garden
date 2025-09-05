class_name GUIPlantDescription
extends VBoxContainer

@onready var _name_label: Label = %NameLabel
@onready var _light_requirement_label: Label = %LightRequirementLabel
@onready var _water_requirement_label: Label = %WaterRequirementLabel
@onready var _rich_text_label: RichTextLabel = %RichTextLabel

func update_with_plant_data(plant_data:PlantData) -> void:
	_name_label.text = plant_data.display_name
	_light_requirement_label.text = str(plant_data.light)
	_water_requirement_label.text = str(plant_data.water)
	var plant_rich_description := plant_data.get_display_description()
	if plant_data.immune_to_status.size() > 0:
		var status_texts := ""
		for status_id in plant_data.immune_to_status:
			status_texts += "{icon_resource_" + status_id + "}" + ", "
		status_texts = status_texts.trim_suffix(", ")
		var status_description := Util.get_localized_string("IMMUNE_TO_STATUS_TEXT") % status_texts
		status_description = Util.format_references(status_description, {}, {}, func(_reference_id:String) -> bool: return false)
		plant_rich_description += "\n" + status_description
	_rich_text_label.text = plant_rich_description
