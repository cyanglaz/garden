class_name PlantStateMachine
extends FiniteStateMachine

var _plant: Plant:get = _get_plant

func _ready() -> void:
	for state in _states.get_children():
		state.plant = _plant

func _get_plant() -> Plant:
	return get_parent() as Plant
