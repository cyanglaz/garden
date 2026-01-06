class_name PlantActionApplier
extends RefCounted

signal action_application_completed()
signal _all_plant_action_application_completed()

var _plant_application_index_counter:int = 0

func apply_action(action:ActionData, plants:Array, plant_index:int) -> void:
	assert(action.action_category == ActionData.ActionCategory.FIELD)
	match action.action_category:
		ActionData.ActionCategory.FIELD:
			var plants_to_apply:Array = []
			if action.specials.has(ActionData.Special.ALL_FIELDS):
				plants_to_apply = plants
				plants_to_apply = plants_to_apply.filter(func(plant:Plant): return !plant.is_bloom())
			else:
				if plant_index >= 0 && plant_index < plants.size():
					plants_to_apply.append(plants[plant_index])
			await _apply_plant_tool_action(action, plants_to_apply)
		_:
			assert(false, "Invalid plant action type: %s" % action.type)
	action_application_completed.emit()

func _apply_plant_tool_action(action:ActionData, plants:Array) -> void:
	if plants.is_empty():
		return
	_plant_application_index_counter = plants.size()
	for plant:Plant in plants:
		plant.action_application_completed.connect(_on_plant_action_application_completed.bind(plant))
		plant.apply_actions([action])
	await _all_plant_action_application_completed

func _on_plant_action_application_completed(plant:Plant) -> void:
	plant.action_application_completed.disconnect(_on_plant_action_application_completed.bind(plant))
	_plant_application_index_counter -= 1
	if _plant_application_index_counter == 0:
		_all_plant_action_application_completed.emit()
