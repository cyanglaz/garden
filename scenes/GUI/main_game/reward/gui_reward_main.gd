class_name GUIRewardMain
extends Control

const PAUSE_TIME_BETWEEN_REWARDS := 0.6

signal reward_finished()

@onready var title_label: Label = %TitleLabel
@onready var gui_reward_gold: GUIRewardGold = %GUIRewardGold
@onready var gui_reward_rating: GUIRewardRating = %GUIRewardRating

func _ready() -> void:
	title_label.text = Util.get_localized_string("REWARD_MAIN_TITLE_TEXT")

func show_with_contract_data(contract_data:ContractData) -> void:
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
	await Singletons.main_game.update_gold(contract_data.reward_gold, true)
	if contract_data.reward_rating > 0:
		await Util.create_scaled_timer(PAUSE_TIME_BETWEEN_REWARDS).timeout
		await Singletons.main_game.update_rating(contract_data.reward_rating)
	reward_finished.emit()
	hide()
