class_name GUITopBar
extends PanelContainer

signal setting_button_evoked()

@onready var _gui_gold: GUIGold = %GUIGold
@onready var _week_label: Label = %WeekLabel
@onready var _gui_settings_button: GUISettingsButton = %GUISettingsButton

func _ready() -> void:
	_gui_settings_button.action_evoked.connect(func() -> void: setting_button_evoked.emit())

func update_gold(gold:int, animated:bool) -> void:
	_gui_gold.update_gold(gold, animated)

func update_week(week:int) -> void:
	_week_label.text = tr("WEEK_LABEL_TEXT") % week

func toggle_all_ui(on:bool) -> void:
	if on:
		_gui_settings_button.button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		_gui_settings_button.button_state = GUIBasicButton.ButtonState.DISABLED
		
