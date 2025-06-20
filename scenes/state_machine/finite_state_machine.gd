class_name FiniteStateMachine
extends Node

signal started()
signal stopped()

@export var default_state: State
@export var init_state: State

@onready var _states: Node = $States

var _current_state: State: set = _set_current_state

var _is_started := false
var _queue:Array

var states_map = {}
	
func _exit_tree() -> void:
	stop()

func start() -> void:
	assert(!_is_started)
	_is_started = true
	assert(default_state != null)
	for state in _states.get_children():
		states_map[state.name] = state
		state.fsm = self
		#_states.remove_child(state)
	assert(init_state != default_state)
	if init_state:
		push(init_state.name)
	else:
		push(default_state.name)
	assert(_current_state)
	started.emit()
	
func stop() -> void:
	if !_is_started:
		return
	_is_started = false
	if _current_state && _current_state.entered:
		_current_state.exit("")
		#_states.remove_child(_current_state)
	#assert(_states.get_child_count() == 0)
	_current_state = null
	_queue.clear()
	stopped.emit()

func push(state_name:String, params:Dictionary = {}) -> void:
	if state_name == default_state.name:
		_set_state_as_current(state_name, params)
	else:
		_queue.push_back([state_name, params])
		if _queue.size() == 1:
			_set_state_as_current(state_name, params)

func push_front(state_name:String, params:Dictionary = {}) -> void:
	if state_name == default_state.name:
		_set_state_as_current(state_name, params)
	else:
		_queue.push_front([state_name, params])
		_set_state_as_current(state_name, params)

func pop() -> void:
	if _queue.size() > 0:
		var next_state_info = _queue.front()
		var state:State = states_map[next_state_info[0]]
		state.params = next_state_info[1]
		_current_state = state
	else:
		_current_state = default_state
		
func get_current_state() -> State:
	return _current_state

func is_started() -> bool:
	return _is_started

func _set_current_state(val:State) -> void:
	var old_state := _current_state
	var new_params:Dictionary = {}
	if val:
		new_params = val.params.duplicate()
	if old_state:
		#assert(_states.get_child_count() == 1)
		old_state.params.clear()
		#_states.remove_child(old_state)
	_current_state = val
	if !_current_state:
		return
	_current_state.params = new_params
	assert(_is_started)
	#_states.add_child(_current_state)
	if !_current_state.state_exited.is_connected(_on_state_exited):
		_current_state.state_exited.connect(_on_state_exited)
	_current_state.enter()
	#if _current_state == default_state:
		##default state should not be in the queue, so we pop it.
		#_queue.pop_front()
		#if _queue.size() > 0:
			## If there are more items left in the queue after setting to the default state, pop again.
			#pop()

func _set_state_as_current(state_name:String, params:Dictionary) -> void:
	var state:State = states_map[state_name]
	state.params = params
	_current_state = state

func _on_state_exited(next_state:String, p:Dictionary) -> void:
	if !_is_started:
		return
	if _current_state == init_state:
		states_map.erase(init_state.name)
		init_state.queue_free()
	assert(_current_state.name == _queue.front()[0])
	_queue.pop_front()
	if next_state == default_state.name:
		_set_state_as_current(next_state, p)
	else:
		if next_state.length() > 0:
			_queue.push_front([next_state, p])
		pop()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for state_name in states_map:
			states_map[state_name].free()
