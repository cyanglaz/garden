class_name State
extends Node2D

@export var log_state:bool = false
@export var next_states:Array[State]

signal state_exited(next_state:String, params:Dictionary)

var entered := false
var fsm:FiniteStateMachine:get = _get_fsm, set = _set_fsm
var params:Dictionary
@warning_ignore("unused_private_class_variable")
var _state_owner:Node2D: get = _get_state_owner
var _weak_state_owner:WeakRef
var _weak_fsm:WeakRef

func enter() -> void:
	if log_state:
		print("enter ", self)
	_weak_state_owner = weakref(fsm.get_parent())
	entered = true

func exit(next_state_name:String, next_params:Dictionary = {}) -> void:
	assert(entered)
	params.clear()
	if log_state:
		print("exit ", self)
	entered = false
	if next_state_name.is_empty() && !next_states.is_empty():
		next_state_name = Util.unweighted_roll(next_states).front().name
	state_exited.emit(next_state_name, next_params)

func _get_state_owner() -> Node2D:
	return _weak_state_owner.get_ref()

func _get_fsm() -> FiniteStateMachine:
	return _weak_fsm.get_ref()

func _set_fsm(val:FiniteStateMachine) -> void:
	_weak_fsm = weakref(val)
	
