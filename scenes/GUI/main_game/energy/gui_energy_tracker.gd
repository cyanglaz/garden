class_name GUIEnergyTracker
extends PanelContainer

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _label: Label = %Label

func bind_with_resource_point(energy_tracker:ResourcePoint) -> void:
	energy_tracker.value_update.connect(_on_energy_tracker_value_updated.bind(energy_tracker, true))
	_on_energy_tracker_value_updated(energy_tracker, false)

func _on_energy_tracker_value_updated(energy_tracker:ResourcePoint, animated:bool) -> void:
	_label.text = str(energy_tracker.value)
	if animated:
		_label.pivot_offset = _label.size/2
		var tween:Tween = Util.create_scaled_tween(_label)
		tween.tween_property(_label, "scale", Vector2.ONE * 2, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(_label, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if energy_tracker.value == 0:
		(_texture_rect.texture as AtlasTexture).region.position.x = 16
		_label.add_theme_color_override("font_color", Constants.COLOR_GRAY1)
	else:
		(_texture_rect.texture as AtlasTexture).region.position.x = 0
		_label.add_theme_color_override("font_color", Constants.COLOR_WHITE)
