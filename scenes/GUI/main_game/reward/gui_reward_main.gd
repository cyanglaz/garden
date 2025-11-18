class_name GUIRewardMain
extends CanvasLayer

const SHOW_ANIMATION_TIME := 0.5

signal reward_finished(tool_data:ToolData, from_global_position:Vector2)

@onready var title_label: Label = %TitleLabel
@onready var gui_reward_gold: GUIRewardGold = %GUIRewardGold
@onready var gui_reward_hp: GUIRewardHP = %GUIRewardHP
@onready var reward_showing_audio: AudioStreamPlayer2D = %RewardShowingAudio
@onready var gui_booster_pack_button: GUIBoosterPackButton = %GUIBoosterPackButton
@onready var margin_container: MarginContainer = %MarginContainer
@onready var gui_reward_cards_main: GUIRewardCardsMain = %GUIRewardCardsMain
@onready var panel_container: PanelContainer = %PanelContainer

var _booster_pack_type:ContractData.BoosterPackType

var _original_panel_y:float

func _ready() -> void:
	title_label.text = Util.get_localized_string("REWARD_MAIN_TITLE_TEXT")
	gui_booster_pack_button.pressed.connect(_booster_pack_button_pressed)
	gui_reward_cards_main.card_selected.connect(_on_card_selected)
	_original_panel_y = panel_container.position.y
	
	var contract_data = ContractData.new()
	show_with_contract_data(contract_data)

func show_with_contract_data(contract_data:ContractData) -> void:
	margin_container.show()
	title_label.show()
	gui_reward_gold.hide()
	gui_reward_hp.hide()
	gui_booster_pack_button.hide()
	_update_with_contract_data(contract_data)
	show()
	PauseManager.try_pause()
	_collect_rewards(contract_data)
	panel_container.position.y = get_viewport().size.y
	reward_showing_audio.play()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(panel_container, "position:y", _original_panel_y, SHOW_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	Events.request_update_gold.emit(contract_data.reward_gold, true)
	if contract_data.reward_hp > 0:
		Events.request_hp_update.emit(contract_data.reward_hp)

func _update_with_contract_data(contract_data:ContractData) -> void:
	gui_reward_gold.update_with_value(contract_data.reward_gold)
	if contract_data.reward_hp > 0:
		gui_reward_hp.update_with_value(contract_data.reward_hp)
	gui_booster_pack_button.update_with_booster_pack_type(contract_data.reward_booster_pack_type)

func _collect_rewards(contract_data:ContractData) -> void:
	gui_reward_gold.show()
	if contract_data.reward_hp > 0:
		gui_reward_hp.show()
	_booster_pack_type = contract_data.reward_booster_pack_type
	gui_booster_pack_button.show()

func _booster_pack_button_pressed() -> void:
	margin_container.hide()
	gui_reward_cards_main.spawn_cards_with_pack_type(_booster_pack_type, gui_booster_pack_button.global_position)

func _on_card_selected(tool_data:ToolData, from_global_position:Vector2) -> void:
	PauseManager.try_unpause()
	reward_finished.emit(tool_data, from_global_position)
