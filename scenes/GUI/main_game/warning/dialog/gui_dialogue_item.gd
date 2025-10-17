class_name GUIDialogueItem
extends PanelContainer

enum DialogueType {
	THING_DETAIL,
	CANNOT_USE_CARD,
	CARD_USE_LIMIT_REACHED,
	CARD_CUSTOM_ERROR,
}

const THING_DETAIL_INPUT_ICON_PATH := "res://resources/sprites/GUI/icons/inputs/input_v.png"
const GOLD_ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_gold.png"

@onready var description: RichTextLabel = %Description
@onready var background: NinePatchRect = %Background
@onready var margin_container: MarginContainer = %MarginContainer

var is_top_item:bool: set = _set_is_top_item
var dialogue_type:DialogueType
var id := ""

func show_with_type(type:DialogueType) -> void:
	dialogue_type = type
	show()
	_update_text()

func show_with_custom_error(message:String, identifier:String) -> void:
	id = identifier
	dialogue_type = DialogueType.CARD_CUSTOM_ERROR
	show()
	description.text = DescriptionParser.format_references(message, {}, {}, func(_reference_id:String) -> bool: return false)

func _update_text() -> void:
	match dialogue_type:
		DialogueType.THING_DETAIL:
			var input_icon_string := str("[img=6x6]", THING_DETAIL_INPUT_ICON_PATH, "[/img]")
			description.text = Util.get_localized_string("SHOW_LIBRARY_TOOLTIP_PROMPT") % [input_icon_string]
		DialogueType.CANNOT_USE_CARD:
			description.text = Util.get_localized_string("WARNING_CANNOT_USE_CARD")
		DialogueType.CARD_USE_LIMIT_REACHED:
			description.text = Util.get_localized_string("WARNING_CARD_USE_LIMIT_REACHED")

func _set_is_top_item(val:bool) -> void:
	is_top_item = val
	if is_top_item:
		background.region_rect.position.x = 0
		background.patch_margin_top = 8
		background.patch_margin_left = 10
		margin_container.add_theme_constant_override("margin_top", 10)
	else:
		background.region_rect.position.x = 16
		background.patch_margin_top = 3
		background.patch_margin_left = 2
		margin_container.add_theme_constant_override("margin_top", 4)
