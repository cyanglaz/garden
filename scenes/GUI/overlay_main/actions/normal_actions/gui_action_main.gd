class_name GUIActionMain
extends PanelContainer

signal action_selected(action_data:ActionData)
signal action_selection_finished()

const ACTION_CARD_SCENE:PackedScene = preload("res://scenes/GUI/controls/buttons/gui_action_button.tscn")

@onready var _cards_container: HBoxContainer = %CardsContainer
@onready var _continue_button: GUIRichTextButton = %ContinueButton
@onready var _appear_audio: AudioStreamPlayer2D = %AppearAudio

var _player:Player: get = _get_player
var _weak_player:WeakRef

func _ready() -> void:
	_continue_button.action_evoked.connect(_on_continue_button_evoked)

func bind_player(player:Player) -> void:
	_weak_player = weakref(player)
	_player.action_point_changed.connect(_on_action_point_changed)
	_refresh_actions()

func animate_show() -> void:
	show()
	_appear_audio.play()
	for card:GUIActionButton in _cards_container.get_children():
		card.handle_show()
	
func _refresh_actions() -> void:
	Util.remove_all_children(_cards_container)
	for action:ActionData in _player.player_data.actions:
		var card:GUIActionButton = ACTION_CARD_SCENE.instantiate()
		_cards_container.add_child(card)
		card.bind_action_data(action, _player)
		card.card_selected.connect(_on_action_card_selected)

func _on_continue_button_evoked() -> void:
	hide()
	action_selection_finished.emit()

func _on_action_card_selected(action_data:ActionData) -> void:
	action_selected.emit(action_data)
	_refresh_actions()

func _get_player() -> Player:
	return _weak_player.get_ref()

func _on_action_point_changed(_new_ap:int) -> void:
	_refresh_actions()
