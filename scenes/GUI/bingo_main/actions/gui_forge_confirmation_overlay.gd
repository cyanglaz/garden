class_name GUIForgeConfirmationOverlay
extends Control

signal forge_confirmed(upgraded_bingo_ball_data:BingoBallData)
signal forge_canceled()

@onready var _from: GUICardRewardButton = %From
@onready var _to: GUICardRewardButton = %To
@onready var _back_button: GUIRichTextButton = %BackButton
@onready var _confirm_button: GUIRichTextButton = %ConfirmButton

var _upgraded_bingo_ball_data:BingoBallData

func _ready() -> void:
	_back_button.action_evoked.connect(on_back_button_pressed)
	_confirm_button.action_evoked.connect(on_confirm_button_pressed)

func animate_show_with_ball_data(bingo_ball_data:BingoBallData) -> void:
	show()
	_from.bind_bingo_ball_data(bingo_ball_data)
	_upgraded_bingo_ball_data = MainDatabase.ball_database.get_data_by_id(bingo_ball_data.upgrade_to_id, true)
	_to.bind_bingo_ball_data(_upgraded_bingo_ball_data, true)
	
func on_back_button_pressed() -> void:
	hide()
	forge_canceled.emit()

func on_confirm_button_pressed() -> void:
	hide()
	forge_confirmed.emit(_upgraded_bingo_ball_data)
