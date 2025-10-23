class_name GUIBossTooltip
extends GUITooltip

@onready var name_label: Label = %NameLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

var library_mode := true
var _weak_boss_data:WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_with_boss_data(boss_data:BossData) -> void:
	_weak_boss_data = weakref(boss_data)
	name_label.text = boss_data.display_name
	name_label.modulate = Constants.CONTRACT_THEME_COLOR_BOSS
	rich_text_label.text = boss_data.get_display_description()

func _on_mouse_entered() -> void:
	Events.update_hovered_data.emit(_weak_boss_data.get_ref())
	has_outline = true

func _on_mouse_exited() -> void:
	Events.update_hovered_data.emit(null)
	has_outline = false
