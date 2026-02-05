class_name Player
extends Node2D

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")
const POPUP_SHOW_TIME := 0.5
const POPUP_DESTROY_TIME := 0.5
const MOVE_TILT_ANGLE := 15.0

signal field_index_updated(index:int)

const MOVE_TIME := 0.1

const POSITION_Y_OFFSET := -30

@onready var player_sprite: PlayerSprite = %PlayerSprite
@onready var player_state_machine: PlayerStateMachine = %PlayerStateMachine
@onready var gui_player_status_container: GUIPlayerStatusContainer = %GUIPlayerStatusContainer
@onready var player_status_container: PlayerStatusContainer = %PlayerStatusContainer

var current_field_index:int = 0: set = _set_current_field_index
var player_data:PlayerData
var max_plants_index:int = 0

func _ready() -> void:
	player_state_machine.start()
	gui_player_status_container.bind_with_player_status_container(player_status_container)
	player_status_container.status_updated.connect(_on_status_updated)

func setup_with_player_data(pd:PlayerData, mpi:int) -> void:
	player_data = pd
	max_plants_index = mpi
	player_status_container.set_status("momentum", pd.starting_movements)

func handle_turn_end() -> void:
	player_status_container.clear_status_on_turn_end()

func toggle_ui_buttons(on:bool) -> void:
	if player_status_container.handle_prevent_movement_hook():
		on = false
	player_status_container.toggle_ui_buttons(on)

func move_to_x(x: float) -> void:
	#var tilt = MOVE_TILT_ANGLE if x > player_sprite.global_position.x else -MOVE_TILT_ANGLE
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	#player_sprite.rotation_degrees = tilt
	tween.tween_property(self, "global_position", Vector2(x, POSITION_Y_OFFSET), MOVE_TIME).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property(player_sprite, "rotation_degrees", 0.0, 0.05).set_delay(MOVE_TIME)

func push_state(state:String, params:Dictionary = {}) -> void:
	player_state_machine.push(state, params)

func update_hp(val:int, operation:ActionData.OperatorType) -> void:
	match operation:
		ActionData.OperatorType.INCREASE:
			push_state("PlayerStateHeal", {"value": val})
		ActionData.OperatorType.DECREASE:
			push_state("PlayerStateHurt", {"value": val})
		ActionData.OperatorType.EQUAL_TO:
			pass

func update_energy(val:int, operation:ActionData.OperatorType) -> void:
	match operation:
		ActionData.OperatorType.INCREASE:
			push_state("PlayerStateUpgradeEnergy", {"value": val})
		ActionData.OperatorType.DECREASE:
			push_state("PlayerStateDecreaseEnergy", {"value": val})
		ActionData.OperatorType.EQUAL_TO:
			pass

func _on_movement_button_pressed(move_direction:PlayerStatusMomentum.MoveDirection) -> void:
	match move_direction:
		PlayerStatusMomentum.MoveDirection.LEFT:
			current_field_index -= 1
		PlayerStatusMomentum.MoveDirection.RIGHT:
			current_field_index += 1
	player_status_container.update_status("momentum", 1, ActionData.OperatorType.DECREASE)

func _set_current_field_index(value:int) -> void:
	assert(max_plants_index > 0)
	current_field_index = value
	var momentum_status:PlayerStatusMomentum = player_status_container.get_status("momentum")
	if momentum_status:
		momentum_status.update_current_field_index(current_field_index, max_plants_index)
	field_index_updated.emit(current_field_index)

func _on_status_updated() -> void:
	for player_status:PlayerStatus in player_status_container.get_all_player_statuses():
		if player_status.status_data.id == "momentum":
			var player_status_momentum:PlayerStatusMomentum = player_status
			if !player_status_momentum.button_pressed.is_connected(_on_movement_button_pressed):
				player_status_momentum.button_pressed.connect(_on_movement_button_pressed)
