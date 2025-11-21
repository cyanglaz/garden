class_name Land
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _gui_field_button: GUIBasicButton = %GUIFieldButton
@onready var _gui_field_selection_arrow: GUIFieldSelectionArrow = %GUIFieldSelectionArrow
@warning_ignore("unused_private_class_variable")
@onready var _container: Node2D = %Container
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _water_droplet_emitter: WaterDropletEmitter = %WaterDropletEmitter

signal field_pressed()
signal field_hovered(hovered:bool)

func _ready() -> void:
	_gui_field_selection_arrow.indicator_state = GUIFieldSelectionArrow.IndicatorState.HIDE
	_gui_field_button.state_updated.connect(_on_gui_field_button_state_updated)
	_gui_field_button.pressed.connect(_on_plant_button_pressed)
	_gui_field_button.mouse_entered.connect(_on_gui_plant_button_mouse_entered)
	_gui_field_button.mouse_exited.connect(_on_gui_plant_button_mouse_exited)


func toggle_selection_indicator(indicator_state:GUIFieldSelectionArrow.IndicatorState) -> void:
	_gui_field_selection_arrow.indicator_state = indicator_state

#region events

func _on_gui_field_button_state_updated(state: GUIBasicButton.ButtonState) -> void:
	match state:
		GUIBasicButton.ButtonState.NORMAL, GUIBasicButton.ButtonState.DISABLED, GUIBasicButton.ButtonState.SELECTED, GUIBasicButton.ButtonState.PRESSED:
			animated_sprite_2d.material.set_shader_parameter("outline_size", 0)
		GUIBasicButton.ButtonState.HOVERED:
			animated_sprite_2d.material.set_shader_parameter("outline_size", 1)

func _on_gui_plant_button_mouse_entered() -> void:
	field_hovered.emit(true)

func _on_gui_plant_button_mouse_exited() -> void:
	field_hovered.emit(false)

func _on_plant_button_pressed() -> void:
	_animation_player.play("dip")
	field_pressed.emit()

func _on_dip_down() -> void:
	# Called in animation player
	_water_droplet_emitter.emit_droplets()
