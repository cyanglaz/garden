class_name Plant
extends Node2D

@onready var plant_sprite: AnimatedSprite2D = %PlantSprite
@onready var fsm: PlantStateMachine = %PlantStateMachine

var light:ResourcePoint = ResourcePoint.new()
var water:ResourcePoint = ResourcePoint.new()

var data:PlantData:set = _set_data
var stage:int:get = _get_stage

func _ready() -> void:
	fsm.start()

func show_as_preview() -> void:
	fsm.push("PlantStatePreview")

func _set_data(value:PlantData) -> void:
	data = value
	light.setup(0, data.light)
	water.setup(0, data.water)

func _get_stage() -> int:
	assert(water.max_value != 0, "Water max value is 0")
	assert(light.max_value != 0, "Light max value is 0")
	if light.is_full && water.is_full:
		return 2
	else:
		return 1
