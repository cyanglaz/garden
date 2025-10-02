class_name Plant
extends Node2D

enum AbilityType {
	HARVEST,
	END_DAY,
	LIGHT_GAIN,
	WEATHER,
	FIELD_STATUS_UPDATE,
}

@warning_ignore("unused_signal")
signal harvest_started()
@warning_ignore("unused_signal")
signal removed_from_field()
@warning_ignore("unused_signal")
signal harvest_completed()
signal ability_triggered(ability_type:AbilityType)

@onready var plant_sprite: AnimatedSprite2D = %PlantSprite
@onready var fsm: PlantStateMachine = %PlantStateMachine
@onready var plant_ability_container: PlantAbilityContainer = %PlantAbilityContainer

var light:ResourcePoint = ResourcePoint.new()
var water:ResourcePoint = ResourcePoint.new()

var data:PlantData:set = _set_data
var field:Field: set = _set_field, get = _get_field
var _weak_field:WeakRef = weakref(null)

func _ready() -> void:
	fsm.start()

func show_as_preview() -> void:
	fsm.push("PlantStatePreview")

func can_harvest() -> bool:
	return light.is_full && water.is_full

func harvest() -> void:
	fsm.push("PlantStateHarvest")

func trigger_ability(ability_type:AbilityType, main_game:MainGame) -> void:
	await Util.await_for_tiny_time()
	await plant_ability_container.trigger_ability(ability_type, main_game, self)
	ability_triggered.emit(ability_type)
#endregion

func _set_data(value:PlantData) -> void:
	data = value
	light.setup(0, data.light)
	water.setup(0, data.water)
	plant_ability_container.setup_with_plant_data(data)

func _set_field(value:Field) -> void:
	_weak_field = weakref(value)

func _get_field() -> Field:
	return _weak_field.get_ref()
