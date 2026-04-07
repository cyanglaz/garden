class_name GUIRewardMain
extends CanvasLayer

const SHOW_ANIMATION_TIME := 0.5

const TRINKET_REWARD_SCENE := preload("res://scenes/GUI/chest/gui_chest_reward_trinket.tscn")
const GUI_REWARD_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_reward_button.tscn")
const TRINKET_ICON_PREFIX := "res://resources/sprites/GUI/icons/trinkets/icon_%s.png"

signal reward_finished()

@export var test_combat_data:CombatData

@onready var title_label: Label = %TitleLabel
@onready var reward_showing_audio: AudioStreamPlayer2D = %RewardShowingAudio
@onready var margin_container: MarginContainer = %MarginContainer
@onready var gui_reward_cards_main: GUIRewardCardsMain = %GUIRewardCardsMain
@onready var panel_container: PanelContainer = %PanelContainer
@onready var main_margin_container: MarginContainer = %MainMarginContainer
@onready var vbox_container: VBoxContainer = %VBoxContainer
@onready var skip_reward_button: GUIRichTextButton = %SkipRewardButton

var _original_panel_y: float
var _original_title_y: float
var _reward_total: int = 0

func _ready() -> void:
	title_label.text = Util.get_localized_string("REWARD_MAIN_TITLE_TEXT")
	#gui_booster_pack_button.pressed.connect(_booster_pack_button_pressed)
	gui_reward_cards_main.reward_finished.connect(_on_card_reward_finished)
	#gui_reward_gold.gold_collected.connect(_on_gold_collected)
	#gui_reward_hp.hp_collected.connect(_on_hp_collected)
	skip_reward_button.pressed.connect(_on_skip_reward_pressed)
	_original_panel_y = panel_container.position.y
	_original_title_y = title_label.position.y

	#show_with_combat_data(test_combat_data, [])

func show_with_data(gold: int, hp: int, booster_pack_type: CombatData.BoosterPackType, trinket_data: TrinketData) -> void:
	Util.remove_all_children(vbox_container)
	margin_container.show()
	title_label.show()

	var gui_reward_gold: GUIRewardButton = GUI_REWARD_BUTTON_SCENE.instantiate()
	vbox_container.add_child(gui_reward_gold)
	var reward_gold_text := DescriptionParser.format_references(Util.get_localized_string("REWARD_GOLD_TEXT") % gold, {}, {}, func(_reference_id:String) -> bool: return false, Constants.COLOR_YELLOW1)
	gui_reward_gold.update_with_texture_and_text(load("res://resources/sprites/GUI/icons/resources/icon_gold.png"), reward_gold_text)
	gui_reward_gold.pressed.connect(_on_gold_collected.bind(gold, gui_reward_gold))
	_reward_total += 1
	if hp > 0:
		var gui_reward_hp: GUIRewardButton = GUI_REWARD_BUTTON_SCENE.instantiate()
		vbox_container.add_child(gui_reward_hp)
		var reward_hp_text := DescriptionParser.format_references(Util.get_localized_string("REWARD_HP_TEXT") % hp, {}, {}, func(_reference_id:String) -> bool: return false, Constants.COLOR_RED1)
		gui_reward_hp.update_with_texture_and_text(load("res://resources/sprites/GUI/icons/resources/icon_vitality.png"), reward_hp_text)
		gui_reward_hp.pressed.connect(_on_hp_collected.bind(hp, gui_reward_hp))
		_reward_total +=1

	if trinket_data:
		var gui_reward_trinket: GUIRewardButton = GUI_REWARD_BUTTON_SCENE.instantiate()
		vbox_container.add_child(gui_reward_trinket)
		gui_reward_trinket.update_with_texture_and_text(load(str(TRINKET_ICON_PREFIX % trinket_data.id)), Util.convert_to_bbc_highlight_text(trinket_data.get_display_name(), Constants.COLOR_WHITE))
		gui_reward_trinket.pressed.connect(_on_trinket_pressed.bind(trinket_data, gui_reward_trinket))
		_reward_total +=1

	var booster_icon_path := ""
	match booster_pack_type:
		CombatData.BoosterPackType.COMMON:
			booster_icon_path = "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_common.png"
		CombatData.BoosterPackType.RARE:
			booster_icon_path = "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_rare.png"
		CombatData.BoosterPackType.LEGENDARY:
			booster_icon_path = "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_legendary.png"

	var gui_booster_pack_button: GUIRewardButton = GUI_REWARD_BUTTON_SCENE.instantiate()
	vbox_container.add_child(gui_booster_pack_button)
	var booster_pack_name_color := Util.get_booster_pack_name_color(booster_pack_type)
	var reward_booster_pack_text := DescriptionParser.format_references(Util.get_localized_string("REWARD_BOOSTER_PACK_TEXT") % CombatData.get_booster_pack_name(booster_pack_type), {}, {}, func(_reference_id:String) -> bool: return false, booster_pack_name_color)
	gui_booster_pack_button.update_with_texture_and_text(load(booster_icon_path), reward_booster_pack_text)
	gui_booster_pack_button.pressed.connect(_booster_pack_button_pressed.bind(booster_pack_type, gui_booster_pack_button))
	_reward_total +=1

	show()
	PauseManager.try_pause()
	panel_container.position.y = main_margin_container.size.y
	title_label.position.y = main_margin_container.size.y
	skip_reward_button.hide()
	reward_showing_audio.play()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(panel_container, "position:y", _original_panel_y, SHOW_ANIMATION_TIME).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(title_label, "position:y", _original_title_y, SHOW_ANIMATION_TIME).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished
	skip_reward_button.show()

func show_with_combat_data(combat_data: CombatData, owned_trinkets:Array[String]) -> void:
	var trinket_datas: Array[TrinketData] = []
	var reward_hp := combat_data.reward_hp
	#if combat_data.reward_trinket:
	trinket_datas = MainDatabase.trinket_database.roll_trinkets(1, owned_trinkets)
	if trinket_datas.is_empty():
		assert(reward_hp == 0, "Reward HP is not 0 when reward trinket is true")
		reward_hp = 1
	var trinket_data := trinket_datas[0] if !trinket_datas.is_empty() else null
	await show_with_data(combat_data.reward_gold, reward_hp, combat_data.reward_booster_pack_type, trinket_data)

func _booster_pack_button_pressed(booster_pack_type: CombatData.BoosterPackType, button:GUIRewardButton) -> void:
	gui_reward_cards_main.spawn_cards_with_pack_type(booster_pack_type, button.global_position)
	button.queue_free()

func _on_gold_collected(gold:int, reward_button:GUIRewardButton) -> void:
	_reward_total -= 1
	reward_button.queue_free()
	Events.request_update_gold.emit(gold, true)
	_try_finish_rewards()

func _on_hp_collected(hp:int, reward_button:GUIRewardButton) -> void:
	_reward_total -= 1
	reward_button.queue_free()
	Events.request_hp_update.emit(hp, ActionData.OperatorType.INCREASE)
	_try_finish_rewards()

func _on_card_reward_finished() -> void:
	_reward_total -= 1
	_try_finish_rewards()

func _on_trinket_pressed(trinket_data:TrinketData, reward_button:GUIRewardButton) -> void:
	var from_position := reward_button.gui_icon.global_position
	reward_button.queue_free()
	Events.request_add_trinket_to_collection.emit(trinket_data, from_position)
	_reward_total -= 1
	_try_finish_rewards()

func _on_skip_reward_pressed() -> void:
	_reward_total = 0
	_try_finish_rewards()

func _try_finish_rewards() -> void:
	if _reward_total == 0:
		PauseManager.try_unpause()
		reward_finished.emit()
