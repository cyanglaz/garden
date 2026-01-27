class_name Player
extends Node2D

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")
const POPUP_SHOW_TIME := 0.5
const POPUP_DESTROY_TIME := 0.5

signal field_index_updated(index:int)

const MOVE_TIME := 0.1

enum MoveDirection {
	LEFT,
	RIGHT
}

const POSITION_Y_OFFSET := -38

@onready var player_sprite: PlayerSprite = %PlayerSprite
@onready var player_state_machine: PlayerStateMachine = %PlayerStateMachine
@onready var left_button: GUIImageButton = %LeftButton
@onready var right_button: GUIImageButton = %RightButton
@onready var move_indicator: Label = %MoveIndicator
@onready var move_ui: Control = %MoveUI
@onready var gui_player_status_container: GUIPlayerStatusContainer = %GUIPlayerStatusContainer
@onready var player_status_container: PlayerStatusContainer = %PlayerStatusContainer

var moves_left:int = 0: set = _set_moves_left
var current_field_index:int = 0: set = _set_current_field_index
var max_plants_index:int = 0
var player_data:PlayerData

func _ready() -> void:
	player_state_machine.start()
	left_button.pressed.connect(_on_button_pressed.bind(MoveDirection.LEFT))
	right_button.pressed.connect(_on_button_pressed.bind(MoveDirection.RIGHT))
	gui_player_status_container.bind_with_player_status_container(player_status_container)

func setup_with_player_data(pd:PlayerData) -> void:
	player_data = pd
	moves_left = pd.starting_movements

func handle_turn_end() -> void:
	player_status_container.handle_status_on_turn_end()

func toggle_move_buttons(on:bool) -> void:
	if player_status_container.handle_prevent_movement_hook():
		on = false
	left_button.button_state = GUIBasicButton.ButtonState.NORMAL if on else GUIBasicButton.ButtonState.DISABLED
	right_button.button_state = GUIBasicButton.ButtonState.NORMAL if on else GUIBasicButton.ButtonState.DISABLED

func move_to_x(x: float) -> void:
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(x, POSITION_Y_OFFSET), MOVE_TIME).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

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

func update_movement(val:int, operation:ActionData.OperatorType) -> void:
	match operation:
		ActionData.OperatorType.INCREASE:
			moves_left += val
			push_state("PlayerStateUpgradeMovement", {"value": val})
		ActionData.OperatorType.DECREASE:
			moves_left -= val
			push_state("PlayerStateDecreaseMovement", {"value": val})
		ActionData.OperatorType.EQUAL_TO:
			moves_left = val

func update_energy(val:int, operation:ActionData.OperatorType) -> void:
	match operation:
		ActionData.OperatorType.INCREASE:
			push_state("PlayerStateUpgradeEnergy", {"value": val})
		ActionData.OperatorType.DECREASE:
			push_state("PlayerStateDecreaseEnergy", {"value": val})
		ActionData.OperatorType.EQUAL_TO:
			pass

func _on_button_pressed(move_direction:MoveDirection) -> void:
	match move_direction:
		MoveDirection.LEFT:
			current_field_index -= 1
		MoveDirection.RIGHT:
			current_field_index += 1
	moves_left -= 1

func _set_moves_left(value:int) -> void:
	moves_left = max(value, 0)
	move_indicator.text = str(moves_left)
	assert(moves_left >= 0)
	move_ui.visible = moves_left > 0
	if moves_left == 0:
		move_indicator.modulate = Constants.COLOR_RED
	else:
		move_indicator.modulate = Constants.COLOR_WHITE

func _set_current_field_index(value:int) -> void:
	assert(max_plants_index > 0)
	current_field_index = value
	if current_field_index == 0:
		left_button.hide()
	else:
		left_button.show()
	if current_field_index == max_plants_index:
		right_button.hide()
	else:
		right_button.show()
	field_index_updated.emit(current_field_index)
