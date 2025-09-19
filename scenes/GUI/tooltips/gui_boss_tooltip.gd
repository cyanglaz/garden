class_name GUIBossTooltip
extends GUITooltip

const CARD_TOOLTIP_DELAY := 0.2

@onready var name_label: Label = %NameLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

var library_mode := true

func update_with_level_data(level_data:LevelData) -> void:
	name_label.text = level_data.display_name
	rich_text_label.text = level_data.get_display_description()
