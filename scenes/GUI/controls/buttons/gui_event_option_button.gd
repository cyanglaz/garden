class_name GUIEventOptionButton
extends GUIBasicButton

const POSITIVE_DESCRIPTION_COLOR := Constants.COLOR_GREEN2
const NEGATIVE_DESCRIPTION_COLOR := Constants.COLOR_RED2

@onready var border: NinePatchRect = %Border
@onready var label: RichTextLabel = %Label

func update_with_option(option:EventOptionData) -> void:
	var action_description:String = str("[", option.get_display_name(), "]")
	var positive_description := ""
	var negative_description := ""
	if !option.positive_description.is_empty():
		positive_description = DescriptionParser.format_references(option.get_display_positive_description(), option.data, {}, func(_reference_id:String) -> bool: return false, POSITIVE_DESCRIPTION_COLOR)
		positive_description = Util.convert_to_bbc_highlight_text(positive_description, POSITIVE_DESCRIPTION_COLOR)
	if !option.negative_description.is_empty():
		negative_description = DescriptionParser.format_references(option.get_display_negative_description(), option.data, {}, func(_reference_id:String) -> bool: return false, NEGATIVE_DESCRIPTION_COLOR)
		negative_description = Util.convert_to_bbc_highlight_text(negative_description, NEGATIVE_DESCRIPTION_COLOR)
	label.text = str(action_description, " ", positive_description, " ", negative_description)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if border:
		match button_state:
			ButtonState.NORMAL:
				mouse_filter = Control.MOUSE_FILTER_STOP
				border.region_rect.position = Vector2(0, 0)
			ButtonState.PRESSED:
				mouse_filter = Control.MOUSE_FILTER_STOP
				border.region_rect.position = Vector2(16, 0)
			ButtonState.HOVERED:
				mouse_filter = Control.MOUSE_FILTER_STOP
				border.region_rect.position = Vector2(32, 0)
			ButtonState.DISABLED:
				border.region_rect.position = Vector2(0, 16)
			ButtonState.SELECTED:
				mouse_filter = Control.MOUSE_FILTER_IGNORE
				border.region_rect.position = Vector2(16, 16)
