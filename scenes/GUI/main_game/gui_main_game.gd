class_name GUIMainGame
extends CanvasLayer

signal rating_update_finished(value:int)

@onready var gui_top_bar: GUITopBar = %GUITopBar

@onready var gui_library: GUILibrary = %GUILibrary
@onready var gui_thing_info_view: GUIThingInfoView = %GUIThingInfoView
@onready var gui_top_animation_overlay: GUITopAnimationOverlay = %GUITopAnimationOverlay
@onready var gui_dialogue_window: GUIDialogueWindow = %GUIDialogueWindow

@onready var _overlay: Control = %Overlay
@onready var _gui_settings_main: GUISettingsMain = %GUISettingsMain
@onready var _gui_tool_cards_viewer: GUIToolCardsViewer = %GUIToolCardsViewer

var _toggle_ui_semaphore := 0

func _ready() -> void:
	_gui_tool_cards_viewer.hide()
	gui_top_bar.setting_button_evoked.connect(_on_settings_button_evoked)
	gui_top_bar.library_button_evoked.connect(_on_library_button_evoked)
	gui_top_bar.rating_update_finished.connect(func(value:int) -> void: rating_update_finished.emit(value))
	gui_top_animation_overlay.setup(self)

	_register_global_events()

func _register_global_events() -> void:
	Events.request_show_info_view.connect(_on_request_show_info_view)
	Events.request_view_cards.connect(_on_request_view_cards)

#region all ui
func toggle_all_ui(on:bool) -> void:
	if on:
		_toggle_ui_semaphore -= 1
	else:
		_toggle_ui_semaphore += 1
	assert(_toggle_ui_semaphore >= 0)
	var toggle_on := false
	if _toggle_ui_semaphore > 0:
		toggle_on = false
	else:
		toggle_on = true
	gui_top_bar.toggle_all_ui(toggle_on)

#region topbar
func update_level(level:int) -> void:
	gui_top_bar.update_level(level)

func update_gold(gold_diff:int, animated:bool) -> void:
	await gui_top_bar.update_gold(gold_diff, animated)

func bind_with_rating(rating:ResourcePoint) -> void:
	gui_top_bar.bind_with_rating(rating)


func show_current_contract(contract_data:ContractData) -> void:
	gui_top_bar.show_current_contract(contract_data)

func hide_current_contract() -> void:
	gui_top_bar.hide_current_contract()

#region characters

func update_player(player_data:PlayerData) -> void:
	gui_top_bar.update_player(player_data)

func bind_cards(cards:Array[ToolData]) -> void:
	gui_top_bar.full_deck_button_evoked.connect(_on_request_view_cards.bind(cards, tr("FULL_DECK_TITLE")))

#endregion

#region days
func update_penalty(penalty:int) -> void:
	gui_top_bar.update_penalty(penalty)


#region control

func add_control_to_overlay(control:Control) -> void:
	_overlay.add_child(control)

func clear_all_tooltips() -> void:
	for child in _overlay.get_children():
		if child is GUITooltip:
			child.queue_free()

#endregion

#region warning
	
#endregion

#region events

func _on_settings_button_evoked() -> void:
	_gui_settings_main.animate_show()

func _on_library_button_evoked() -> void:
	gui_library.animate_show()

#endregion

#region global events

func _on_request_show_info_view(data:Resource) -> void:
	gui_thing_info_view.show_with_data(data)

func _on_request_view_cards(cards:Array, title:String) -> void:
	_gui_tool_cards_viewer.animated_show_with_pool(cards, title)

#endregion
