class_name GUIBossTooltip
extends GUITooltip

const CARD_TOOLTIP_DELAY := 0.2

@onready var name_label: Label = %NameLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

var card_tooltips:Array[WeakRef] = []
var _weak_level_data:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	tool_tip_shown.connect(_on_tooltop_shown)

func update_with_level_data(level_data:LevelData) -> void:
	_weak_level_data = weakref(level_data)
	name_label.text = level_data.display_name
	rich_text_label.text = level_data.get_display_description()

func _on_tooltop_shown() -> void:
	await Util.create_scaled_timer(CARD_TOOLTIP_DELAY).timeout
	var tool_ids:Array[String] = Util.find_tool_ids_in_data(_weak_level_data.get_ref().data)
	for tool_id:String in tool_ids:
		var tool_data := MainDatabase.tool_database.get_data_by_id(tool_id)
		card_tooltips.append(weakref(Util.display_card_tooltip(tool_data, self, false, self.tooltip_position)))

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for weak_card_tooltip in card_tooltips:
			if weak_card_tooltip.get_ref():
				weak_card_tooltip.get_ref().queue_free()
				weak_card_tooltip = weakref(null)
