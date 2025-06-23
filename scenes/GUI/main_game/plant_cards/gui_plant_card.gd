class_name GUIPlantCard
extends HBoxContainer

signal plant_button_action_evoked()

@onready var _gui_plant_button: GUIPlantButton = %GUIPlantButton

var _weak_plant_tooltip:WeakRef = weakref(null)
var _weak_plant_data:WeakRef

func _ready() -> void:
	_gui_plant_button.action_evoked.connect(func(): plant_button_action_evoked.emit())
	_gui_plant_button.mouse_entered.connect(_on_mouse_entered)
	_gui_plant_button.mouse_exited.connect(_on_mouse_exited)

func update_with_plant_data(plant_data:PlantData) -> void:
	_weak_plant_data = weakref(plant_data)
	_gui_plant_button.update_with_plant_data(plant_data)

func _on_mouse_entered() -> void:
	_weak_plant_tooltip = weakref(Util.display_plant_tooltip(_weak_plant_data.get_ref(), self, false, GUITooltip.TooltipPosition.RIGHT))

func _on_mouse_exited() -> void:
	if _weak_plant_tooltip.get_ref():
		_weak_plant_tooltip.get_ref().queue_free()
		_weak_plant_tooltip = weakref(null)
