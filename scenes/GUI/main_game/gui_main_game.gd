class_name GUIMainGame
extends CanvasLayer

const DETAIL_TOOLTIP_DELAY := 0.8


@onready var gui_top_bar: GUITopBar = %GUITopBar

@onready var gui_library: GUILibrary = %GUILibrary
@onready var gui_thing_info_view: GUIThingInfoView = %GUIThingInfoView
@onready var gui_top_animation_overlay: GUITopAnimationOverlay = %GUITopAnimationOverlay
@onready var gui_dialogue_window: GUIDialogueWindow = %GUIDialogueWindow
@onready var gui_tooltips_container: GUITooltipContainer = %GUITooltipsContainer

@onready var _gui_game_over_main: GUIGameOverMain = %GUIGameOverMain
@onready var _gui_settings_main: GUISettingsMain = %GUISettingsMain
@onready var _gui_tool_cards_viewer: GUIToolCardsViewer = %GUIToolCardsViewer
@onready var _transition_overlay: TransitionOverlay = %TransitionOverlay

var _toggle_ui_semaphore := 0
var _hovered_data:ThingData

func _ready() -> void:
	_gui_tool_cards_viewer.hide()
	gui_top_bar.setting_button_evoked.connect(_on_settings_button_evoked)
	gui_top_bar.library_button_evoked.connect(_on_library_button_evoked)
	gui_top_animation_overlay.setup(self)

	_register_global_events()

func _register_global_events() -> void:
	Events.request_show_info_view.connect(_on_request_show_info_view)
	Events.request_view_cards.connect(_on_request_view_cards)
	Events.update_hovered_data.connect(_on_update_hovered_data)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("view_detail"):
		_show_info_view()

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

func bind_with_hp(hp:ResourcePoint) -> void:
	gui_top_bar.bind_with_hp(hp)

func animate_hp_update(value:int) -> void:
	await gui_top_bar.animate_hp_update(value)

#region characters

func update_player(player_data:PlayerData) -> void:
	gui_top_bar.update_player(player_data)

func bind_cards(cards:Array[ToolData]) -> void:
	gui_top_bar.full_deck_button_evoked.connect(_on_request_view_cards.bind(cards, tr("FULL_DECK_TITLE")))

#endregion

#region transitions

func transition(type:TransitionOverlay.Type, duration:float = 0.4) -> void:
	await _transition_overlay.transition(type, duration)

#endregion

#region gameover

func game_over() -> void:
	_gui_game_over_main.animate_show()

#endregion

#region private

func _clear_tooltips() -> void:
	gui_tooltips_container.clear_all_tooltips()
	gui_dialogue_window.clear_all_dialogue_items()

func _show_info_view() -> void:
	if !_hovered_data:
		return
	_clear_tooltips()
	gui_thing_info_view.show_with_data(_hovered_data)
	_hovered_data = null

#endregion

#region events

func _on_settings_button_evoked() -> void:
	_clear_tooltips()
	_gui_settings_main.animate_show()

func _on_library_button_evoked() -> void:
	_clear_tooltips()
	gui_library.animate_show()

#endregion

#region global events

func _on_request_view_cards(cards:Array, title:String) -> void:
	_gui_tool_cards_viewer.animated_show_with_pool(cards, title)

func _on_request_show_info_view(data:Resource) -> void:
	_hovered_data = data
	_show_info_view()

func _on_update_hovered_data(data:Resource) -> void:
	_hovered_data = data
	if _hovered_data:
		await Util.create_scaled_timer(DETAIL_TOOLTIP_DELAY).timeout
		if _hovered_data:
			Events.request_show_warning.emit(WarningManager.WarningType.DIALOGUE_THING_DETAIL)
	else:
		Events.request_hide_warning.emit(WarningManager.WarningType.DIALOGUE_THING_DETAIL)

#endregion
