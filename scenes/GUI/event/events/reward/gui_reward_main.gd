class_name GUIRewardMain
extends CanvasLayer

const SHOW_ANIMATION_TIME := 0.5

const TRINKET_REWARD_SCENE := preload("res://scenes/GUI/chest/gui_chest_reward_trinket.tscn")

signal reward_finished()

@onready var title_label: Label = %TitleLabel
@onready var gui_reward_gold: GUIRewardGold = %GUIRewardGold
@onready var gui_reward_hp: GUIRewardHP = %GUIRewardHP
@onready var reward_showing_audio: AudioStreamPlayer2D = %RewardShowingAudio
@onready var gui_booster_pack_button: GUIBoosterPackButton = %GUIBoosterPackButton
@onready var margin_container: MarginContainer = %MarginContainer
@onready var gui_reward_cards_main: GUIRewardCardsMain = %GUIRewardCardsMain
@onready var panel_container: PanelContainer = %PanelContainer
@onready var main_margin_container: MarginContainer = %MainMarginContainer
@onready var vbox_container: VBoxContainer = %VBoxContainer

var _booster_pack_type: CombatData.BoosterPackType
var _trinket_data: TrinketData = null
var _gui_reward_trinket: GUIChestRewardTrinket = null
var _trinket_collected: bool = true
var _card_collected: bool = false

var _original_panel_y: float

func _ready() -> void:
	title_label.text = Util.get_localized_string("REWARD_MAIN_TITLE_TEXT")
	gui_booster_pack_button.pressed.connect(_booster_pack_button_pressed)
	gui_reward_cards_main.reward_finished.connect(_on_reward_finished)
	_original_panel_y = panel_container.position.y

	#var combat_data = CombatData.new()
	#show_with_combat_data(combat_data)

func show_with_data(gold: int, hp: int, booster_pack_type: CombatData.BoosterPackType) -> void:
	margin_container.show()
	title_label.show()
	gui_reward_gold.hide()
	gui_reward_hp.hide()
	gui_booster_pack_button.hide()
	gui_reward_gold.update_with_value(gold)
	if hp > 0:
		gui_reward_hp.update_with_value(hp)
	gui_booster_pack_button.update_with_booster_pack_type(booster_pack_type)
	_collect_rewards(gold, hp, booster_pack_type)
	show()
	PauseManager.try_pause()
	panel_container.position.y = main_margin_container.size.y
	reward_showing_audio.play()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(panel_container, "position:y", _original_panel_y, SHOW_ANIMATION_TIME).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished
	if gold > 0:
		Events.request_update_gold.emit(gold, true)
	if hp > 0:
		Events.request_hp_update.emit(hp, ActionData.OperatorType.INCREASE)

func show_with_combat_data(combat_data: CombatData) -> void:
	_card_collected = false
	if combat_data.reward_trinket:
		_trinket_data = MainDatabase.trinket_database.roll_trinket([])
		_trinket_collected = false
	else:
		_trinket_data = null
		_trinket_collected = true
	await show_with_data(combat_data.reward_gold, combat_data.reward_hp, combat_data.reward_booster_pack_type)

func _collect_rewards(gold: int, hp: int, booster_pack_type: CombatData.BoosterPackType) -> void:
	if gold > 0:
		gui_reward_gold.show()
	if hp > 0:
		gui_reward_hp.show()
	if _trinket_data != null:
		_gui_reward_trinket = TRINKET_REWARD_SCENE.instantiate()
		vbox_container.add_child(_gui_reward_trinket)
		vbox_container.move_child(_gui_reward_trinket, gui_booster_pack_button.get_index())
		_gui_reward_trinket.update_with_trinket_data(_trinket_data)
		_gui_reward_trinket.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_gui_reward_trinket.trinket_selected.connect(_on_trinket_pressed)
	_booster_pack_type = booster_pack_type
	gui_booster_pack_button.show()

func _booster_pack_button_pressed() -> void:
	margin_container.hide()
	gui_reward_cards_main.spawn_cards_with_pack_type(_booster_pack_type, gui_booster_pack_button.global_position)

func _on_reward_finished() -> void:
	_card_collected = true
	_try_finish_rewards()

func _on_trinket_pressed() -> void:
	var from_position := _gui_reward_trinket.global_position
	_gui_reward_trinket.queue_free()
	_gui_reward_trinket = null
	Events.request_add_trinket_to_collection.emit(_trinket_data, from_position)
	_trinket_collected = true
	_try_finish_rewards()

func _try_finish_rewards() -> void:
	if _card_collected and _trinket_collected:
		PauseManager.try_unpause()
		reward_finished.emit()
	elif _card_collected:
		gui_booster_pack_button.hide()
		margin_container.show()
