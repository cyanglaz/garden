class_name GUIEnergyTracker
extends PanelContainer

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _label: Label = %Label

func bind_with_resource_point(energy_tracker:ResourcePoint) -> void:
	energy_tracker.value_update.connect(_on_energy_tracker_value_updated.bind(energy_tracker))
	_on_energy_tracker_value_updated(energy_tracker)

func _on_energy_tracker_value_updated(energy_tracker:ResourcePoint) -> void:
	_label.text = str(energy_tracker.value)
	if energy_tracker.value == 0:
		(_texture_rect.texture as AtlasTexture).region.position.x = 16
		_label.add_theme_color_override("font_color", Constants.COLOR_GRAY1)
	else:
		(_texture_rect.texture as AtlasTexture).region.position.x = 0
		_label.add_theme_color_override("font_color", Constants.COLOR_WHITE)
