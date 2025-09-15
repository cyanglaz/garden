class_name PowerData
extends ThingData

var power_script:PowerScript: get = _get_power_script

var stack := 0

var _power_script:PowerScript

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_power_data := other as PowerData
	stack = other_power_data.stack

func get_duplicate() -> PowerData:
	var dup:PowerData = PowerData.new()
	dup.copy(self)
	return dup

func _get_power_script() -> PowerScript:
	if _power_script:
		return _power_script
	return _create_power_script()

func _create_power_script() -> PowerScript:
	var path := Util.get_script_path_for_power_id(id)
	if ResourceLoader.exists(path):
		_power_script = load(path).new(self)
		_power_script.power_data = self
	return _power_script
