@tool
extends Node


const WAIT_TIME_IN_SECONDS := 0.8
var _energy := 0.0
var _scheduled := false

## Schedule a file system scan. This method works like a debouncer
## postponing the scan until no more calls are being made
func schedule_file_system_scan() -> void:
	_energy = WAIT_TIME_IN_SECONDS
	_scheduled = true


func _process(delta: float) -> void:
	if _scheduled:
		if _energy > 0.0:
			_energy -= delta
		else:
			_scheduled = false
			EditorInterface.get_resource_filesystem().scan.call_deferred()
