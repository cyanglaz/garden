class_name PlantState
extends State

var plant: Plant:get = _get_plant, set = _set_plant
var _weak_plant: WeakRef = weakref(null)

func enter() -> void:
	super.enter()
	plant.plant_sprite.play(_get_animation_name())

func _set_plant(value: Plant) -> void:
	_weak_plant = weakref(value)

func _get_plant() -> Plant:
	return _weak_plant.get_ref()

func _get_animation_name() -> String:
	return ""
