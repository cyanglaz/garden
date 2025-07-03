class_name GUIEnergyTracker
extends PanelContainer

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _label: Label = %Label

func bind_with_resource_point(energy_tracker:ResourcePoint) -> void:
	energy_tracker.value_update.connect(_on_energy_tracker_value_updated.bind(energy_tracker))
	_on_energy_tracker_value_updated(energy_tracker)

func _on_energy_tracker_value_updated(energy_tracker:ResourcePoint) -> void:
	_label.text = str(energy_tracker.value)
