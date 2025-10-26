class_name GUIRewardMain
extends CanvasLayer

const REWARD_SOUND_1 := preload("res://resources/sounds/SFX/summary/reward_1.wav")
const REWARD_SOUND_2 := preload("res://resources/sounds/SFX/summary/reward_2.wav")
const REWARD_SOUND_3 := preload("res://resources/sounds/SFX/summary/reward_3.wav")
const PAUSE_TIME_BETWEEN_REWARDS := 1.0
const PAUSE_BEFORE_REWARD_ANIMATION := 0.4

signal reward_finished(tool_data:ToolData, from_global_position:Vector2)

@onready var title_label: Label = %TitleLabel
@onready var gui_reward_gold: GUIRewardGold = %GUIRewardGold
@onready var gui_reward_rating: GUIRewardRating = %GUIRewardRating
@onready var reward_showing_audio: AudioStreamPlayer2D = %RewardShowingAudio
@onready var gui_booster_pack_button: GUIBoosterPackButton = %GUIBoosterPackButton
@onready var margin_container: MarginContainer = %MarginContainer
@onready var gui_reward_cards_main: GUIRewardCardsMain = %GUIRewardCardsMain

var _reward_sound_index := 0
var _booster_pack_type:ContractData.BoosterPackType

func _ready() -> void:
	title_label.text = Util.get_localized_string("REWARD_MAIN_TITLE_TEXT")
	gui_booster_pack_button.pressed.connect(_booster_pack_button_pressed)
	gui_reward_cards_main.card_selected.connect(_on_card_selected)

func show_with_contract_data(contract_data:ContractData) -> void:
	margin_container.show()
	title_label.show()
	gui_reward_gold.hide()
	gui_reward_rating.hide()
	gui_booster_pack_button.hide()
	_update_with_contract_data(contract_data)
	show()
	await _collect_rewards(contract_data)

func _update_with_contract_data(contract_data:ContractData) -> void:
	gui_reward_gold.update_with_value(contract_data.reward_gold)
	if contract_data.reward_rating > 0:
		gui_reward_rating.show()
		gui_reward_rating.update_with_value(contract_data.reward_rating)
	else:
		gui_reward_rating.hide()
	gui_booster_pack_button.update_with_booster_pack_type(contract_data.reward_booster_pack_type)

func _collect_rewards(contract_data:ContractData) -> void:
	await Util.create_scaled_timer(PAUSE_TIME_BETWEEN_REWARDS).timeout
	_play_next_reward_sound()
	gui_reward_gold.show()
	await Util.create_scaled_timer(PAUSE_BEFORE_REWARD_ANIMATION).timeout
	Events.request_update_gold.emit(contract_data.reward_gold, true)
	if contract_data.reward_rating > 0:
		await Util.create_scaled_timer(PAUSE_TIME_BETWEEN_REWARDS).timeout
		_play_next_reward_sound()
		gui_reward_rating.show()
		await Util.create_scaled_timer(PAUSE_BEFORE_REWARD_ANIMATION).timeout
		Events.request_rating_update.emit(contract_data.reward_rating)
	await Util.create_scaled_timer(PAUSE_TIME_BETWEEN_REWARDS).timeout
	_play_next_reward_sound()
	_booster_pack_type = contract_data.reward_booster_pack_type
	gui_booster_pack_button.show()

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

func _booster_pack_button_pressed() -> void:
	margin_container.hide()
	gui_reward_cards_main.spawn_cards_with_pack_type(_booster_pack_type, gui_booster_pack_button.global_position)

func _on_card_selected(tool_data:ToolData, from_global_position:Vector2) -> void:
	reward_finished.emit(tool_data, from_global_position)
