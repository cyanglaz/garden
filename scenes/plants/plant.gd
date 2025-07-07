class_name Plant
extends Node2D

enum AbilityType {
	HARVEST,
	END_DAY,
}

@warning_ignore("unused_signal")
signal harvest_started()
@warning_ignore("unused_signal")
signal harvest_gold_gained(gold:int)
@warning_ignore("unused_signal")
signal harvest_completed()
signal ability_triggered(ability_type:AbilityType)
signal stage_updated()

@onready var plant_sprite: AnimatedSprite2D = %PlantSprite
@onready var fsm: PlantStateMachine = %PlantStateMachine

var light:ResourcePoint = ResourcePoint.new()
var water:ResourcePoint = ResourcePoint.new()

var data:PlantData:set = _set_data
var stage:int = 1
var field:Field: set = _set_field, get = _get_field
var _weak_field:WeakRef = weakref(null)

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

func trigger_ability(ability_type:AbilityType, main_game:MainGame) -> void:
	var hook_result := await field.status_manager.handle_ability_hook(ability_type, self)
	if hook_result == FieldStatusScript.HookResultType.ABORT:
		await Util.await_for_tiny_time()
		ability_triggered.emit(ability_type)
		return
	else:
		await _trigger_ability(ability_type, main_game)

func _trigger_ability(ability_type:AbilityType, _main_game:MainGame) -> void:
	await Util.await_for_tiny_time()
	ability_triggered.emit(ability_type)

func _set_data(value:PlantData) -> void:
	data = value
	light.setup(0, data.light)
	water.setup(0, data.water)

func _set_field(value:Field) -> void:
	_weak_field = weakref(value)

func _get_field() -> Field:
	return _weak_field.get_ref()

func _update_stage_if_possible() -> void:
	if (light.value + water.value) * 2 >= light.max_value + water.max_value && stage == 1:
		stage = 2
		stage_updated.emit()

func _on_light_value_update() -> void:
	_update_stage_if_possible()

func _on_water_value_update() -> void:
	_update_stage_if_possible()
