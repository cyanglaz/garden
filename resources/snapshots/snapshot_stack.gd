class_name SnapshotStack
extends RefCounted

var _snapshot_stack := []
var _snapshot_index := 0

func clear() -> void:
	_snapshot_stack.clear()
	_snapshot_index = 0

func can_undo() -> bool:
	return _snapshot_index > 0

func can_redo() -> bool:
	assert(_snapshot_index <= _snapshot_stack.size(), "snapshot stack index out of bounds")
	return _snapshot_index < _snapshot_stack.size() - 1

func clear_back_stack() -> void:
	while _snapshot_stack.size() - 1 > _snapshot_index:
		_snapshot_stack.pop_back()
	
func push_data(data:Dictionary) -> void:
	_snapshot_stack.append(data)
	_snapshot_index = _snapshot_stack.size() - 1

func load_data(index_diff := 0) -> Dictionary:
	var new_snapshot_index := _snapshot_index + index_diff
	if new_snapshot_index < 0 or new_snapshot_index >= _snapshot_stack.size():
		return {}
	_snapshot_index = new_snapshot_index
	return _snapshot_stack[_snapshot_index]

func undo_get_data() -> Dictionary:
	return load_data(-1)

func redo_get_data() -> Dictionary:
	return load_data(1)
