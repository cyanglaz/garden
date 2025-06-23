class_name Field
extends Node2D

const PLANT_SCENE_PATH_PREFIX := "res://scenes/plants/plants/plant_"

signal field_pressed()
signal field_hovered(hovered:bool)

@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _gui_field_button: GUIBasicButton = %GUIFieldButton
@onready var _light_bar: GUISegmentedProgressBar = %LightBar
@onready var _water_bar: GUISegmentedProgressBar = %WaterBar
@onready var _plant_container: Node2D = %PlantContainer

var _weak_plant_preview:WeakRef = weakref(null)

func _ready() -> void:
	_gui_field_button.state_updated.connect(_on_gui_field_button_state_updated)
	_gui_field_button.action_evoked.connect(func(): field_pressed.emit())
	_gui_field_button.mouse_entered_button.connect(func(): field_hovered.emit(true))
	_gui_field_button.mouse_exited_button.connect(func(): field_hovered.emit(false))
	_animated_sprite_2d.play("idle")

func show_plant_preview(plant_data:PlantData) -> void:
	var plant_scene_path := PLANT_SCENE_PATH_PREFIX + plant_data.id + ".tscn"
	var scene := load(plant_scene_path)
	var plant_preview:Plant = scene.instantiate()
	_plant_container.add_child(plant_preview)
	plant_preview.data = plant_data
	plant_preview.show_as_preview()
	_weak_plant_preview = weakref(plant_preview)

func remove_plant_preview() -> void:
	if _weak_plant_preview.get_ref():
		_weak_plant_preview.get_ref().queue_free()

func _on_gui_field_button_state_updated(state: GUIBasicButton.ButtonState) -> void:
	match state:
		GUIBasicButton.ButtonState.NORMAL, GUIBasicButton.ButtonState.DISABLED, GUIBasicButton.ButtonState.SELECTED:
			_animated_sprite_2d.play("idle")
		GUIBasicButton.ButtonState.HOVERED:
			_animated_sprite_2d.play("hover")
		GUIBasicButton.ButtonState.PRESSED:
			_animated_sprite_2d.play("pressed")
