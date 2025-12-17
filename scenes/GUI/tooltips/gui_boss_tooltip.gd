class_name GUIBossTooltip
extends GUITooltip

@onready var name_label: Label = %NameLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

var library_mode := true

func _ready() -> void:
	super._ready()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _update_with_tooltip_request() -> void:
	var boss_data:BossData = _tooltip_request.data as BossData
	name_label.text = boss_data.get_display_name()
	name_label.modulate = Constants.COMBAT_THEME_COLOR_BOSS
	rich_text_label.text = boss_data.get_display_description()

func _on_mouse_entered() -> void:
	Events.update_hovered_data.emit(_tooltip_request.data)
	has_outline = true

func _on_mouse_exited() -> void:
	Events.update_hovered_data.emit(null)
	has_outline = false
