class_name GUIDescriptionRichTextLabel
extends RichTextLabel

const META_ANCHOR_RECT_OFFSET := 4.0

@export var tooltip_position:GUITooltip.TooltipPosition

var _weak_mouse_over_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	meta_hover_started.connect(_on_meta_hover_started)
	meta_hover_ended.connect(_on_meta_hover_ended)
	meta_underlined = false

func _on_meta_hover_started(meta:Variant) -> void:
	mouse_default_cursor_shape = Control.CursorShape.CURSOR_HELP
	if meta.begins_with("status_effect_"):
		var status_effect_id:String = meta.replace("status_effect_", "")
		var reference_status_effect_data:StatusEffectData = MainDatabase.status_effect_database.get_data_by_id(status_effect_id)
		_weak_mouse_over_tooltip = weakref(Util.display_status_effect_tooltip(reference_status_effect_data, null, true, tooltip_position))
	elif meta.begins_with("space_effect_"):
		var space_effect_id:String = meta.replace("space_effect_", "")
		var reference_space_effect_data:SpaceEffectData = MainDatabase.space_effect_database.get_data_by_id(space_effect_id)
		var space_effect:SpaceEffect = SpaceEffect.new(reference_space_effect_data, 0)
		_weak_mouse_over_tooltip = weakref(Util.display_space_effect_tooltip(space_effect, null, true, tooltip_position))
	if _weak_mouse_over_tooltip.get_ref():
		var anchor_rect:Rect2 = Rect2(get_global_mouse_position()+Vector2.UP*META_ANCHOR_RECT_OFFSET+Vector2.LEFT*META_ANCHOR_RECT_OFFSET, Vector2(META_ANCHOR_RECT_OFFSET*2, META_ANCHOR_RECT_OFFSET*2))
		_weak_mouse_over_tooltip.get_ref().triggering_global_rect = anchor_rect

func _on_meta_hover_ended(meta:String) -> void:
	if meta.begins_with("ball_") \
	|| meta.begins_with("status_effect_") \
	|| meta.begins_with("space_effect_"):
		mouse_default_cursor_shape = Control.CursorShape.CURSOR_ARROW
