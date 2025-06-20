class_name GUIAttuneConfirmationOverlay
extends Control

signal attune_confirmed(removed_bingo_ball_data:BingoBallData)
signal attune_canceled()

@onready var _from: GUICardRewardButton = %From
@onready var _back_button: GUIRichTextButton = %BackButton
@onready var _confirm_button: GUIRichTextButton = %ConfirmButton

var _removing_bingo_ball_data:BingoBallData

func _ready() -> void:
	_back_button.action_evoked.connect(on_back_button_pressed)
	_confirm_button.action_evoked.connect(on_confirm_button_pressed)

func animate_show_with_ball_data(bingo_ball_data:BingoBallData) -> void:
	show()
	_from.bind_bingo_ball_data(bingo_ball_data)
	_removing_bingo_ball_data = bingo_ball_data
	
func on_back_button_pressed() -> void:
	hide()
	attune_canceled.emit()

func on_confirm_button_pressed() -> void:
	hide()
	attune_confirmed.emit(_removing_bingo_ball_data)
	_removing_bingo_ball_data = null
