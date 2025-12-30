class_name GUITopBar
extends PanelContainer

const DETAIL_TOOLTIP_ICON_PATH := "res://resources/sprites/GUI/icons/inputs/input_v.png"

signal setting_button_evoked()
signal full_deck_button_evoked()
signal library_button_evoked()

@onready var gui_full_deck_button: GUIDeckButton = %GUIFullDeckButton
@onready var gui_gold: GUIGold = %GUIGold
@onready var _gui_settings_button: GUISettingsButton = %GUISettingsButton
@onready var _gui_player: GUICharacter = %GUIPlayer
@onready var _gui_library_button: GUILibraryButton = %GUILibraryButton
@onready var _guihp: GUIHP = %GUIHP

func _ready() -> void:
	_gui_settings_button.pressed.connect(func() -> void: setting_button_evoked.emit())
	gui_full_deck_button.pressed.connect(func() -> void: full_deck_button_evoked.emit())
	_gui_library_button.pressed.connect(func() -> void: library_button_evoked.emit())

func bind_with_hp(hp:ResourcePoint) -> void:
	_guihp.bind_with_hp(hp)

func animate_hp_update(value:int) -> void:
	await _guihp.animate_hp_update(value)

func update_gold(gold_diff:int, animated:bool) -> void:
	await gui_gold.update_gold(gold_diff, GUIGold.AnimationType.FULL if animated else GUIGold.AnimationType.NONE)
	
func update_player(player_data:PlayerData) -> void:
	_gui_player.update_with_player_data(player_data)

func toggle_all_ui(_on:bool) -> void:
	pass
		
