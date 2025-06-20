class_name GUIAttuneMain
extends Control

signal attune_completed()
signal attune_canceled()

const BINGO_BALL_BUTTON_SCENE:PackedScene = preload("res://scenes/GUI/controls/buttons/gui_bingo_ball_button.tscn")

@onready var _gui_popup_container: GUIPopupContainer = %GUIPopupContainer
@onready var _grid_container: GridContainer = %GridContainer
@onready var _gui_attune_confirmation_overlay: GUIAttuneConfirmationOverlay = %GUIAttuneConfirmationOverlay
@onready var _back_button: GUIRichTextButton = %BackButton

var _selected_ball_data:BingoBallData: get = get_selected_ball_data, set = set_selected_ball_data
var _weak_selected_bingo_ball:WeakRef = weakref(null)

func _ready() -> void:
	_gui_attune_confirmation_overlay.attune_confirmed.connect(_on_attune_confirmed)
	_gui_attune_confirmation_overlay.attune_canceled.connect(_on_attune_canceled)
	_back_button.action_evoked.connect(_on_back_button_evoked)

func animate_show_with_balls(balls:Array[BingoBallData]) -> void:
	show()
	Util.remove_all_children(_grid_container)
	for ball_data:BingoBallData in balls:
		var button:GUIBingoBallButton = BINGO_BALL_BUTTON_SCENE.instantiate()
		button.action_evoked.connect(_on_attune_ball_selected.bind(ball_data))
		_grid_container.add_child(button)
		button.bind_bingo_ball(ball_data)
	await _gui_popup_container.animate_show()

func animate_hide() -> void:
	_gui_popup_container.animate_hide()
	hide()

func _on_attune_ball_selected(ball_data:BingoBallData) -> void:
	_selected_ball_data = ball_data
	_gui_attune_confirmation_overlay.animate_show_with_ball_data(_selected_ball_data)

func get_selected_ball_data() -> BingoBallData:
	return _weak_selected_bingo_ball.get_ref()

func set_selected_ball_data(value:BingoBallData) -> void:
	_weak_selected_bingo_ball = weakref(value)

func _on_attune_confirmed(removed_bingo_ball_data:BingoBallData) -> void:
	Singletons.game_main._player.draw_box.remove_ball(removed_bingo_ball_data)
	_gui_attune_confirmation_overlay.hide()
	animate_hide()
	attune_completed.emit()

func _on_attune_canceled() -> void:
	_gui_attune_confirmation_overlay.hide()

func _on_back_button_evoked() -> void:
	animate_hide()
	attune_canceled.emit()
