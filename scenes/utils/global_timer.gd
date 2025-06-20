extends Timer

class_name GlobalTimer

var _seconds:float

signal timer_update(seconds:float)

func _on_timeout():
	_seconds += wait_time
	timer_update.emit(_seconds)
	
func get_passed_time() -> float:
	return _seconds;
