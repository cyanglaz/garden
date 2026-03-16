class_name GUIChestRewardContainer
extends Control

signal trinket_reward_selected()

const INITIAL_SCALE_FACTOR: float = 0.5
const SPAWN_TRANSITION_TIME := 0.4

const TRINKET_REWARD_SCENE := preload("res://scenes/GUI/chest/gui_chest_reward_trinket.tscn")

func spawn_trinket(trinket_data: TrinketData, spawn_position: Vector2) -> void:
	Util.remove_all_children(self)
	if trinket_data == null:
		return
	var gui_reward_trinket: GUIChestRewardTrinket = TRINKET_REWARD_SCENE.instantiate()
	add_child(gui_reward_trinket)
	gui_reward_trinket.hide()
	gui_reward_trinket.mouse_disabled = true
	gui_reward_trinket.update_with_trinket_data(trinket_data)
	gui_reward_trinket.trinket_selected.connect(_on_trinket_reward_selected.bind(trinket_data, gui_reward_trinket))
	await _animate_spawn(spawn_position)
	gui_reward_trinket.mouse_disabled = false

func _animate_spawn(spawn_position: Vector2) -> void:
	var child: GUIChestRewardTrinket = get_child(0)
	child.global_position = spawn_position
	child.scale = Vector2.ONE * INITIAL_SCALE_FACTOR
	child.show()
	await get_tree().process_frame
	var tween: Tween = Util.create_scaled_tween(self)
	var target_position := Vector2(
		(size.x - child.size.x) / 2.0,
		(size.y - child.size.y) / 2.0
	)
	tween.set_parallel(true)
	tween.tween_property(child, "global_position", target_position, SPAWN_TRANSITION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(child, "scale", Vector2.ONE, SPAWN_TRANSITION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func _on_trinket_reward_selected(trinket_data: TrinketData, gui_trinket: GUIChestRewardTrinket) -> void:
	var from_global_position := gui_trinket.global_position
	gui_trinket.hide()
	Events.request_add_trinket_to_collection.emit(trinket_data, from_global_position)
	trinket_reward_selected.emit()
