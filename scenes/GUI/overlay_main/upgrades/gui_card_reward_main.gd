@tool
class_name GUICardRewardMain
extends PanelContainer

signal card_reward_finished(bingo_ball_data:BingoBallData)

const CARD_REWARD_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_card_reward_button.tscn")

@onready var _cards_container: HBoxContainer = %CardsContainer
@onready var _skip_button: GUIRichTextButton = %SkipButton
@warning_ignore("unused_private_class_variable")
@onready var _appear_audio: AudioStreamPlayer2D = %AudioStreamPlayer2D

func _ready() -> void:
	_skip_button.action_evoked.connect(_on_skip_button_evoked)
	
func show_with_balls(bingo_ball_datas:Array[BingoBallData]) -> void:
	show()
	Util.remove_all_children(_cards_container)
	_appear_audio.play()
	var index:int = 0
	for bingo_ball_data:BingoBallData in bingo_ball_datas:
		var reward_card:GUICardRewardButton = CARD_REWARD_BUTTON_SCENE.instantiate()
		reward_card.action_evoked.connect(_on_reward_card_evoked.bind(bingo_ball_datas, index))
		_cards_container.add_child(reward_card) 
		reward_card.bind_bingo_ball_data(bingo_ball_data)
		@warning_ignore("integer_division")
		if index > (bingo_ball_datas.size() - 1) / 2:
			reward_card._gui_ball_description.tooltip_position = GUITooltip.TooltipPosition.LEFT
		else:
			reward_card._gui_ball_description.tooltip_position = GUITooltip.TooltipPosition.RIGHT
		index += 1

func _on_skip_button_evoked() -> void:
	Util.remove_all_children(_cards_container)
	hide()
	card_reward_finished.emit(null)

func _on_reward_card_evoked(bingo_ball_datas:Array[BingoBallData], index:int) -> void:
	Util.remove_all_children(_cards_container)
	hide()
	card_reward_finished.emit(bingo_ball_datas[index])
