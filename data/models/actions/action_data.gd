class_name ActionData
extends ThingData

const ACTION_SCRIPT_PREFIX:String = "res://scenes/rewards/action_scripts/action_script_"

@export var cost:int

var action_script:ActionScript:get = _get_action_script
var _action_script:ActionScript	

func copy(other:ThingData) -> void:
	super.copy(other)
	_action_script = _create_action_script()
	cost = other.cost

func get_duplicate() -> ThingData:
	var action_data:ActionData = ActionData.new()
	action_data.copy(self)
	return action_data
	
func get_display_description() -> String:
	var formatted_description := description.format(data)
	return formatted_description

func _get_action_script() -> ActionScript:
	if _action_script:
		return _action_script
	return _create_action_script()

func _create_action_script() -> ActionScript:
	var path := str(ACTION_SCRIPT_PREFIX, id, ".gd")
	assert(ResourceLoader.exists(path))
	_action_script = load(path).new(self)
	return _action_script
