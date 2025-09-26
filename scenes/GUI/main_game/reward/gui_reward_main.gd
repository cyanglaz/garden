class_name GUIRewardMain
extends Control

const REWARD_SOUND_1 := preload("res://resources/sounds/SFX/summary/reward_1.wav")
const REWARD_SOUND_2 := preload("res://resources/sounds/SFX/summary/reward_2.wav")
const REWARD_SOUND_3 := preload("res://resources/sounds/SFX/summary/reward_3.wav")
const PAUSE_TIME_BETWEEN_REWARDS := 0.6
const PAUSE_BEFORE_REWARD_ANIMATION := 0.4

signal reward_finished()

@onready var title_label: Label = %TitleLabel
@onready var gui_reward_gold: GUIRewardGold = %GUIRewardGold
@onready var gui_reward_rating: GUIRewardRating = %GUIRewardRating
@onready var reward_showing_audio: AudioStreamPlayer2D = %RewardShowingAudio

var _reward_sound_index := 0

func _ready() -> void:
	title_label.text = Util.get_localized_string("REWARD_MAIN_TITLE_TEXT")

func show_with_contract_data(contract_data:ContractData) -> void:
	gui_reward_gold.hide()
	gui_reward_rating.hide()
	_update_with_contract_data(contract_data)
	show()
	await _collect_rewards(contract_data)

func _update_with_contract_data(
	contract_data:ContractData) -> void:
	gui_reward_gold.update_with_value(contract_data.reward_gold)
	if contract_data.reward_rating > 0:
		gui_reward_rating.update_with_value(contract_data.reward_rating)
	else:
		gui_reward_rating.hide()

func _collect_rewards(contract_data:ContractData) -> void:
	await Util.create_scaled_timer(PAUSE_TIME_BETWEEN_REWARDS).timeout
	_play_next_reward_sound()
	gui_reward_gold.show()
	await Util.create_scaled_timer(PAUSE_BEFORE_REWARD_ANIMATION).timeout
	await Singletons.main_game.update_gold(contract_data.reward_gold, true)
	if contract_data.reward_rating > 0:
		await Util.create_scaled_timer(PAUSE_TIME_BETWEEN_REWARDS).timeout
		_play_next_reward_sound()
		gui_reward_rating.show()
		await Util.create_scaled_timer(PAUSE_BEFORE_REWARD_ANIMATION).timeout
		await Singletons.main_game.update_rating(contract_data.reward_rating)
	reward_finished.emit()
	hide()

func _play_next_reward_sound() -> void:
	var stream:AudioStream
	match _reward_sound_index:
		0:
			stream = REWARD_SOUND_1
		1:
			stream = REWARD_SOUND_2
		2:
			stream = REWARD_SOUND_3
	reward_showing_audio.stream = stream
	reward_showing_audio.play()
	_reward_sound_index += 1
