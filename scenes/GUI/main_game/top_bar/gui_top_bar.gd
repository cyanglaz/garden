class_name GUITopBar
extends PanelContainer

const DETAIL_TOOLTIP_ICON_PATH := "res://resources/sprites/GUI/icons/inputs/input_v.png"

signal setting_button_evoked()
signal full_deck_button_evoked()
signal library_button_evoked()
signal rating_update_finished(value:int)
signal contract_button_evoked(contract_data:ContractData)

@onready var gui_full_deck_button: GUIDeckButton = %GUIFullDeckButton
@onready var _gui_gold: GUIGold = %GUIGold
@onready var _gui_settings_button: GUISettingsButton = %GUISettingsButton
@onready var _day_label: Label = %DayLabel
@onready var _gui_player: GUICharacter = %GUIPlayer
@onready var _gui_library_button: GUILibraryButton = %GUILibraryButton
@onready var _gui_rating: GUIRating = %GUIRating
@onready var _gui_boss_icon: GUIBossIcon = %GUIBossIcon
@onready var _gui_current_contract_button: GUICurrentContractButton = %GUICurrentContractButton

var _weak_contract_data:WeakRef = weakref(null)

func _ready() -> void:
	_gui_settings_button.pressed.connect(func() -> void: setting_button_evoked.emit())
	gui_full_deck_button.pressed.connect(func() -> void: full_deck_button_evoked.emit())
	_gui_library_button.pressed.connect(func() -> void: library_button_evoked.emit())
	_gui_rating.rating_update_finished.connect(func(value:int) -> void: rating_update_finished.emit(value))
	_gui_current_contract_button.pressed.connect(func() -> void: contract_button_evoked.emit(_weak_contract_data.get_ref()))

func show_boss_icon(boss_data:BossData) -> void:
	_gui_boss_icon.show()
	_gui_boss_icon.update_with_boss_data(boss_data)

func hide_boss_icon() -> void:
	_gui_boss_icon.hide()

func show_current_contract(contract_data:ContractData) -> void:
	_weak_contract_data = weakref(contract_data)
	_gui_current_contract_button.show()

func hide_current_contract() -> void:
	_gui_current_contract_button.hide()

func bind_with_rating(rating:ResourcePoint) -> void:
	_gui_rating.bind_with_rating(rating)

func update_gold(gold_diff:int, animated:bool) -> void:
	await _gui_gold.update_gold(gold_diff, GUIGold.AnimationType.FULL if animated else GUIGold.AnimationType.NONE)

func update_day_left(day_left:int, penalty_per_day:int) -> void:
	if day_left >= 0:
		_day_label.text = Util.get_localized_string("DAY_LABEL_TEXT")% day_left
		_day_label.modulate = Constants.COLOR_BLUE_2
	else:
		_day_label.text = Util.get_localized_string("AFTER_GRACE_PERIOD_LABEL_TEXT")% penalty_per_day
		_day_label.modulate = Constants.COLOR_RED

func update_player(player_data:PlayerData) -> void:
	_gui_player.update_with_player_data(player_data)

func toggle_all_ui(_on:bool) -> void:
	pass
		
