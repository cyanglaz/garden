class_name GUIPlantAbilityDescription
extends VBoxContainer

const ACTIVE_COLOR := Constants.COLOR_GREEN2
const INACTIVE_COLOR := Constants.COLOR_GRAY2

@onready var texture_rect: TextureRect = %TextureRect
@onready var title_label: Label = %TitleLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var active_label: Label = %ActiveLabel

func update_with_plant_ability_data(plant_ability_data:PlantAbilityData, active:bool) -> void:
	var image := Util.get_image_path_for_resource_id(plant_ability_data.id)
	if image:
		texture_rect.texture = load(Util.get_image_path_for_resource_id(plant_ability_data.id))
	else:
		texture_rect.hide()
	title_label.text = plant_ability_data.display_name
	rich_text_label.text = plant_ability_data.get_display_description()
	if active:
		active_label.text = Util.get_localized_string("PLANT_ABILITY_ACTIVE")
		active_label.add_theme_color_override("font_color", ACTIVE_COLOR)
	else:
		active_label.text = Util.get_localized_string("PLANT_ABILITY_INACTIVE")
		active_label.add_theme_color_override("font_color", INACTIVE_COLOR)
