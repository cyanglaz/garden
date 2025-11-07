class_name Field
extends Node2D

const PLANT_SCENE_PATH_PREFIX:String = "res://scenes/main_game/plants/plants/plant_"

const WIDTH := 32

signal field_pressed()
signal field_hovered(hovered:bool)
signal action_application_completed()
signal plant_harvest_started()
signal plant_harvest_completed()
signal new_plant_planted()

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _gui_field_button: GUIBasicButton = %GUIFieldButton
@onready var _progress_bars: VBoxContainer = %ProgressBars
@onready var _light_bar: GUISegmentedProgressBar = %LightBar
@onready var _water_bar: GUISegmentedProgressBar = %WaterBar
@onready var _gui_field_status_container: GUIFieldStatusContainer = %GUIFieldStatusContainer
@onready var _complete_check: TextureRect = %CompleteCheck
@onready var _gui_plant_ability_icon_container: GUIPlantAbilityIconContainer = %GUIPlantAbilityIconContainer
@onready var _gui_field_selection_arrow: GUIFieldSelectionArrow = %GUIFieldSelectionArrow
@onready var _plant_down_sound: AudioStreamPlayer2D = %PlantDownSound
@onready var _plant_container: Node2D = %PlantContainer
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

var plant:Plant
var index:int = -1
var _tooltip_id:String = ""

func _ready() -> void:
	_light_bar.segment_color = Constants.LIGHT_THEME_COLOR
	_water_bar.segment_color = Constants.WATER_THEME_COLOR
	_progress_bars.hide()
	_complete_check.hide()
	_gui_field_selection_arrow.indicator_state = GUIFieldSelectionArrow.IndicatorState.HIDE
	_gui_field_button.state_updated.connect(_on_gui_field_button_state_updated)
	_gui_field_button.pressed.connect(_on_plant_button_pressed)
	_gui_field_button.mouse_entered.connect(_on_gui_plant_button_mouse_entered)
	_gui_field_button.mouse_exited.connect(_on_gui_plant_button_mouse_exited)

func plant_seed(plant_data:PlantData, combat_main:CombatMain) -> void:
	assert(plant == null, "Plant already planted")
	_plant_down_sound.play()
	var plant_scene_path := PLANT_SCENE_PATH_PREFIX + plant_data.id + ".tscn"
	var scene := load(plant_scene_path)
	plant = scene.instantiate()
	_plant_container.add_child(plant)
	plant.data = plant_data
	_progress_bars.show()
	_light_bar.bind_with_resource_point(plant.light)
	_water_bar.bind_with_resource_point(plant.water)
	plant.harvest_started.connect(func(): plant_harvest_started.emit())
	plant.harvest_completed.connect(func(): plant_harvest_completed.emit())
	plant.action_application_completed.connect(func(): action_application_completed.emit())
	_gui_plant_ability_icon_container.setup_with_plant(plant)
	_gui_field_status_container.bind_with_field_status_manager(plant.status_manager)
	await plant.trigger_ability(Plant.AbilityType.ON_PLANT, combat_main)
	new_plant_planted.emit()

func toggle_selection_indicator(indicator_state:GUIFieldSelectionArrow.IndicatorState) -> void:
	_gui_field_selection_arrow.indicator_state = indicator_state

func show_tooltip() -> void:
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.PLANT, plant.data, _tooltip_id, _gui_field_button, false, GUITooltip.TooltipPosition.BOTTOM, true)

func hide_tooltip() -> void:
	Events.request_hide_tooltip.emit(_tooltip_id)

func get_preview_icon_global_position(preview_icon:Control) -> Vector2:
	return Util.get_node_canvas_position(_gui_field_button) + Vector2.RIGHT * (_gui_field_button.size.x/2 - preview_icon.size.x/2 ) + Vector2.UP * preview_icon.size.y/2

func can_harvest() -> bool:
	return plant.is_grown()

func harvest(combat_main:CombatMain) -> void:
	_progress_bars.hide()
	_gui_field_button.hide()
	_gui_plant_ability_icon_container.hide()
	_gui_field_status_container.hide()
	_gui_field_selection_arrow.hide()
	_complete_check.show()
	plant.harvest(combat_main)

#region events

func _on_gui_field_button_state_updated(state: GUIBasicButton.ButtonState) -> void:
	match state:
		GUIBasicButton.ButtonState.NORMAL, GUIBasicButton.ButtonState.DISABLED, GUIBasicButton.ButtonState.SELECTED:
			if plant:
				plant.plant_sprite.material.set_shader_parameter("outline_size", 0)
			animated_sprite_2d.material.set_shader_parameter("outline_size", 0)
		GUIBasicButton.ButtonState.HOVERED:
			if plant:
				plant.plant_sprite.material.set_shader_parameter("outline_size", 1)
			animated_sprite_2d.material.set_shader_parameter("outline_size", 1)
		GUIBasicButton.ButtonState.PRESSED:
			if plant:
				plant.plant_sprite.material.set_shader_parameter("outline_size", 0)
			animated_sprite_2d.material.set_shader_parameter("outline_size", 0)

func _on_gui_plant_button_mouse_entered() -> void:
	if plant:
		Events.update_hovered_data.emit(plant.data)
	field_hovered.emit(true)

func _on_gui_plant_button_mouse_exited() -> void:
	Events.update_hovered_data.emit(null)
	field_hovered.emit(false)

func _on_plant_button_pressed() -> void:
	_animation_player.play("dip")
	field_pressed.emit()
