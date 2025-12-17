class_name GUIPlantAbilityDescription
extends VBoxContainer

const ACTIVE_COLOR := Constants.COLOR_GREEN5
const INACTIVE_COLOR := Constants.COLOR_GRAY3
const HINT_COLOR := Constants.COLOR_RED

@onready var texture_rect: TextureRect = %TextureRect
@onready var title_label: Label = %TitleLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var active_label: Label = %ActiveLabel
@onready var activate_hint_label: RichTextLabel = %ActivateHintLabel
@onready var cooldown_label: RichTextLabel = %CooldownLabel

func update_with_plant_ability_data(plant_ability_data:PlantAbilityData, stack:int) -> void:
	var image := Util.get_image_path_for_resource_id(plant_ability_data.id)
	if image:
		texture_rect.texture = load(Util.get_image_path_for_resource_id(plant_ability_data.id))
	else:
		texture_rect.hide()
	plant_ability_data.data["stack"] = str(stack)
	title_label.text = plant_ability_data.get_display_name()
	rich_text_label.text = plant_ability_data.get_display_description()
	activate_hint_label.hide()
	if plant_ability_data.cooldown > 0:
		cooldown_label.show()
		var cooldown_text = Util.get_localized_string("PLANT_ABILITY_COOLDOWN") % [plant_ability_data.cooldown]
		cooldown_label.text = Util.convert_to_bbc_highlight_text(cooldown_text, Constants.COLOR_RED3, 1, Constants.COLOR_BEIGE_1)
	else:
		cooldown_label.hide()
