class_name WeatherComponentContainer
extends Node2D

signal animated_in_finished()
signal animated_out_finished()

var _components:Array[WeatherComponent]
var _components_animation_count := 0

func _ready() -> void:
	for child in get_children():
		assert(child is WeatherComponent, "Child is not a WeatherComponent")
		child.animated_in_finished.connect(_on_component_animated_in_finished)
		child.animated_out_finished.connect(_on_component_animated_out_finished)
		_components.append(child)

func animate_components_in() -> void:
	if _components.is_empty():
		return
	_components_animation_count = _components.size()
	for component in _components:
		component.animate_in()
	await animated_in_finished

func animate_components_out() -> void:
	if _components.is_empty():
		return
	_components_animation_count = _components.size()
	for component in _components:
		component.animate_out()
	await animated_out_finished

func _on_component_animated_in_finished() -> void:
	_components_animation_count -= 1
	if _components_animation_count == 0:
		animated_in_finished.emit()

func _on_component_animated_out_finished() -> void:
	_components_animation_count -= 1
	if _components_animation_count == 0:
		animated_out_finished.emit()
