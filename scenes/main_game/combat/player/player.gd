class_name Player
extends Node2D

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")
const POPUP_SHOW_TIME := 0.5
const POPUP_DESTROY_TIME := 0.5
const MOVE_TILT_ANGLE := 15.0

signal field_index_updated(from:int, to:int)
signal player_upgrade_activated(player_upgrade:PlayerUpgrade)
signal player_upgrade_stack_updated(id:String, diff:int)

const MOVE_TIME := 0.1

const POSITION_Y_OFFSET := -30

@onready var player_sprite: PlayerSprite = %PlayerSprite
@onready var player_state_machine: PlayerStateMachine = %PlayerStateMachine
@onready var gui_player_status_container: GUIPlayerStatusContainer = %GUIPlayerStatusContainer
@onready var player_status_container: PlayerStatusContainer = %PlayerStatusContainer
@onready var player_trinkets_container: PlayerTrinketsContainer = %PlayerTrinketsContainer

var current_field_index:int = 0: set = _set_current_field_index
var player_data:PlayerData
var max_plants_index:int = 0
var player_upgrades_manager: PlayerUpgradesManager = PlayerUpgradesManager.new()

func _ready() -> void:
	player_state_machine.start()
	gui_player_status_container.bind_with_player_status_container(player_status_container)
	player_status_container.player_upgrades_updated.connect(_on_player_upgrades_updated)
	player_upgrades_manager.player_upgrade_activated.connect(func(player_upgrade:PlayerUpgrade): player_upgrade_activated.emit(player_upgrade))
	player_upgrades_manager.player_upgrade_stack_updated.connect(func(id:String, diff:int): player_upgrade_stack_updated.emit(id, diff))

func setup(pd:PlayerData, mpi:int, trinket_datas:Array) -> void:
	player_data = pd
	max_plants_index = mpi
	player_status_container.set_player_upgrade("momentum", pd.starting_movements)
	player_trinkets_container.setup_with_trinket_datas(trinket_datas)
	player_upgrades_manager.setup([player_status_container, player_trinkets_container])

func handle_start_turn(combat_main:CombatMain) -> void:
	player_upgrades_manager.handle_start_turn_hook(combat_main)

func handle_hand_size(combat_main: CombatMain) -> int:
	return await player_upgrades_manager.handle_hand_size_hook(combat_main)

func handle_turn_end(combat_main:CombatMain) -> void:
	player_status_container.clear_status_on_turn_end()
	player_status_container.clear_single_turn_player_upgrades()
	await player_upgrades_manager.handle_end_turn_hook(combat_main)

func toggle_ui_buttons(on:bool) -> void:
	if player_upgrades_manager.handle_prevent_movement_hook():
		on = false
	player_upgrades_manager.toggle_ui_buttons(on)

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

func _update_movement(move_direction:PlayerStatusMomentum.MoveDirection) -> void:
	match move_direction:
		PlayerStatusMomentum.MoveDirection.LEFT:
			current_field_index -= 1
		PlayerStatusMomentum.MoveDirection.RIGHT:
			current_field_index += 1
	player_status_container.update_player_upgrade("momentum", 1, ActionData.OperatorType.DECREASE)

func _on_movement_button_pressed(move_direction:PlayerStatusMomentum.MoveDirection) -> void:
	var request = CombatQueueRequest.new()
	request.callback = func(_combat_main:CombatMain) -> void: _update_movement(move_direction)
	request.unique_id = "movement_button_pressed"
	request.only_when_empty = true
	Events.request_combat_queue_push.emit(request)

func _set_current_field_index(value:int) -> void:
	assert(max_plants_index > 0)
	var previous_index:int = current_field_index
	current_field_index = value
	var momentum_status:PlayerStatusMomentum = player_status_container.get_player_upgrade("momentum")
	if momentum_status:
		momentum_status.update_current_field_index(current_field_index, max_plants_index)
	field_index_updated.emit(previous_index, current_field_index)

func _on_player_upgrades_updated() -> void:
	for player_status:PlayerStatus in player_status_container.get_all_player_upgrades():
		if player_status.data.id == "momentum":
			var player_status_momentum:PlayerStatusMomentum = player_status
			if !player_status_momentum.button_pressed.is_connected(_on_movement_button_pressed):
				player_status_momentum.button_pressed.connect(_on_movement_button_pressed)
