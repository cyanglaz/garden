class_name Player
extends Node2D

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")
const HP_INCREASE_COLOR := Constants.COLOR_RED1
const HP_DECREASE_COLOR := Constants.COLOR_RED3
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
@onready var player_hurt_audio: AudioStreamPlayer2D = %PlayerHurtAudio

var moves_left:int = 0: set = _set_moves_left
var current_field_index:int = 0: set = _set_current_field_index
var max_plants_index:int = 0
var player_data:PlayerData

func _ready() -> void:
	player_state_machine.start()
	left_button.pressed.connect(_on_button_pressed.bind(MoveDirection.LEFT))
	right_button.pressed.connect(_on_button_pressed.bind(MoveDirection.RIGHT))

func setup_with_player_data(pd:PlayerData) -> void:
	player_data = pd
	moves_left = pd.starting_movements

func toggle_move_buttons(on:bool) -> void:
	left_button.button_state = GUIBasicButton.ButtonState.NORMAL if on else GUIBasicButton.ButtonState.DISABLED
	right_button.button_state = GUIBasicButton.ButtonState.NORMAL if on else GUIBasicButton.ButtonState.DISABLED

func move_to_x(x: float) -> void:
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(x, POSITION_Y_OFFSET), MOVE_TIME).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func play_hurt_animation(popup_text:String) -> void:
	player_sprite.play_hurt()
	Events.request_camera_shake_effects.emit(0.5, Vector2(20, 20), 0.2, 1.0, 0)
	var popup:PopupLabel = POPUP_LABEL_SCENE.instantiate()
	popup.bump_direction = PopupThing.BumpDirection.UP
	var color:Color = HP_DECREASE_COLOR
	popup.setup(popup_text, color, 10)
	Events.request_display_popup_things.emit(popup, 20, 5, POPUP_SHOW_TIME, POPUP_DESTROY_TIME, Util.get_node_canvas_position(player_sprite))
	player_hurt_audio.play()

func play_heal_animation(_popup_text:String) -> void:
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
