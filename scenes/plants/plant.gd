class_name Plant
extends Node2D

@warning_ignore("unused_signal")
signal harvest_started()
@warning_ignore("unused_signal")
signal harvest_gold_gained(gold:int)
@warning_ignore("unused_signal")
signal harvest_completed()
signal harvest_ability_triggered()
signal end_day_ability_triggered()
signal stage_updated()

@onready var plant_sprite: AnimatedSprite2D = %PlantSprite
@onready var fsm: PlantStateMachine = %PlantStateMachine

var light:ResourcePoint = ResourcePoint.new()
var water:ResourcePoint = ResourcePoint.new()

var data:PlantData:set = _set_data
var stage:int = 1

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

func trigger_harvest_ability() -> void:
	await _trigger_harvest_ability()

func trigger_end_day_ability(weather_data:WeatherData, day:int) -> void:
	await _trigger_end_day_ability(weather_data, day)

func _trigger_harvest_ability() -> void:
	await Util.await_for_tiny_time()
	harvest_ability_triggered.emit()

func _trigger_end_day_ability(_weather_data:WeatherData, _day:int) -> void:
	await Util.await_for_tiny_time()
	end_day_ability_triggered.emit()

func _set_data(value:PlantData) -> void:
	data = value
	light.setup(0, data.light)
	water.setup(0, data.water)

func _update_stage_if_possible() -> void:
	if (light.value + water.value) * 2 >= light.max_value + water.max_value && stage == 1:
		stage = 2
		stage_updated.emit()

func _on_light_value_update() -> void:
	_update_stage_if_possible()

func _on_water_value_update() -> void:
	_update_stage_if_possible()
