class_name Plant
extends Node2D

@warning_ignore("unused_signal")
signal harvest_started()
@warning_ignore("unused_signal")
signal harvest_gold_gained(gold:int)
@warning_ignore("unused_signal")
signal harvest_completed()

@onready var plant_sprite: AnimatedSprite2D = %PlantSprite
@onready var fsm: PlantStateMachine = %PlantStateMachine

var light:ResourcePoint = ResourcePoint.new()
var water:ResourcePoint = ResourcePoint.new()

var data:PlantData:set = _set_data
var stage:int:get = _get_stage

func _ready() -> void:
	fsm.start()
	light.value_update.connect(_on_light_value_update)
	water.value_update.connect(_on_water_value_update)

func show_as_preview() -> void:
	fsm.push("PlantStatePreview")

func can_harvest() -> bool:
	return light.is_full && water.is_full

func harvest() -> void:
	fsm.push("PlantStateHarvest")

func _set_data(value:PlantData) -> void:
	data = value
	light.setup(0, data.light)
	water.setup(0, data.water)

func _get_stage() -> int:
	assert(water.max_value != 0, "Water max value is 0")
	assert(light.max_value != 0, "Light max value is 0")
	if (light.value + water.value) * 2 >= light.max_value + water.max_value:
		return 2
	else:
		return 1

func _on_light_value_update() -> void:
	if can_harvest():
		harvest()

func _on_water_value_update() -> void:
	if can_harvest():
		harvest()
