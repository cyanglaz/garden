class_name Field
extends Node2D

const PLANT_SCENE_PATH_PREFIX := "res://scenes/main_game/plants/plants/plant_"
const POPUP_LABEL_ICON_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label_icon.tscn")
const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")
const GUI_GENERAL_ACTION_SCENE := preload("res://scenes/GUI/main_game/actions/gui_general_action.tscn")
const GUI_WEATHER_ACTION_SCENE := preload("res://scenes/GUI/main_game/actions/gui_weather_action.tscn")
const point_LABEL_OFFSET := Vector2.RIGHT * 12
const POPUP_SHOW_TIME := 0.3
const POPUP_DESTROY_TIME:= 1.2
const ACTION_ICON_MOVE_TIME := 0.3

signal new_plant_planted()

@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _plant_container: Node2D = %PlantContainer
@onready var _point_audio: AudioStreamPlayer2D = %PointAudio
@onready var _gui_plant_ability_icon_container: GUIPlantAbilityIconContainer = %GUIPlantAbilityIconContainer
@onready var _plant_down_sound: AudioStreamPlayer2D = %PlantDownSound

var plant:Plant
var weak_left_field:WeakRef = weakref(null)
var weak_right_field:WeakRef = weakref(null)

var _tooltip_id:String = ""

func _ready() -> void:
	#status_manager.update_status("pest", 1)
	_animated_sprite_2d.play("idle")

func plant_seed(plant_data:PlantData, combat_main:CombatMain) -> void:
	assert(plant == null, "Plant already planted")
	_plant_down_sound.play()
	var plant_scene_path := PLANT_SCENE_PATH_PREFIX + plant_data.id + ".tscn"
	var scene := load(plant_scene_path)
	plant = scene.instantiate()
	_plant_container.add_child(plant)
	plant.data = plant_data
	plant.field = self
	_gui_plant_ability_icon_container.setup_with_plant(plant)
	await plant.trigger_ability(Plant.AbilityType.ON_PLANT, combat_main)
	new_plant_planted.emit()

#region events
