class_name PowerData
extends ThingData

const POWER_SCRIPT_PATH := "res://scenes/bingo/power_scripts/power_script_"

@export var cd:int

var cd_counter:int = 0
var power_script:PowerScript: get = _get_power_script

var _power_script:PowerScript

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_power_data := other as PowerData
	cd = other_power_data.cd
	_power_script = _create_power_script()

func get_duplicate() -> PowerData:
	var dup:PowerData = PowerData.new()
	dup.copy(self)
	return dup

func get_display_description(comparison:bool) -> String:
	var formatted_description = _formate_references(description, data, func(reference_id:String) -> bool:
		if comparison:
			var upgraded_from_data:PowerData = _get_upgraded_from_data()
			if upgraded_from_data.data.has(reference_id):
				if upgraded_from_data.data[reference_id] != data[reference_id]:
					return true
		return false
	)
	return formatted_description

func _get_upgraded_from_data() -> PowerData:
	assert(!upgraded_from_id.is_empty(), "upgraded_from_id is empty")
	return MainDatabase.power_database.get_data_by_id(upgraded_from_id)

func _create_power_script() -> PowerScript:
	var path := Util.get_script_path_for_power_id(id)
	if ResourceLoader.exists(path):
		_power_script = load(path).new(self)
		_power_script.power_data = self
	return _power_script

func _get_power_script() -> PowerScript:
	if !_power_script:
		_power_script = _create_power_script()
	return _power_script
