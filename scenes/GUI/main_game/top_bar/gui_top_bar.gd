class_name GUITopBar
extends PanelContainer

signal setting_button_evoked()
signal full_deck_button_evoked()

@onready var gui_full_deck_button: GUIDeckButton = %GUIFullDeckButton
@onready var _gui_gold: GUIGold = %GUIGold
@onready var _week_label: Label = %WeekLabel
@onready var _gui_settings_button: GUISettingsButton = %GUISettingsButton
@onready var _gui_tax_due: GUITaxDue = %GUITaxDue

func _ready() -> void:
	_gui_settings_button.action_evoked.connect(func() -> void: setting_button_evoked.emit())
	gui_full_deck_button.action_evoked.connect(func() -> void: full_deck_button_evoked.emit())

func update_gold(gold:int, animated:bool) -> void:
	await _gui_gold.update_gold(gold, GUIGold.AnimationType.SINGLE if animated else GUIGold.AnimationType.NONE)

func update_week(week:int) -> void:
	_week_label.text = Util.get_localized_string("WEEK_LABEL_TEXT") % (week + 1)

func update_tax_due(gold:int) -> void:
	_gui_tax_due.update_tax_due(gold)

func toggle_all_ui(on:bool) -> void:
	if on:
		_gui_settings_button.button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		_gui_settings_button.button_state = GUIBasicButton.ButtonState.DISABLED
		
