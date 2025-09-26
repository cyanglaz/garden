class_name GUIMainGame
extends CanvasLayer

signal end_turn_button_pressed()
signal tool_selected(tool_data:ToolData)
signal plant_seed_drawn_animation_completed(field_index:int, plant_data:PlantData)
signal rating_update_finished(value:int)
signal reward_finished()
signal contract_selected(contract_data:ContractData)

@onready var gui_top_bar: GUITopBar = %GUITopBar
@onready var game_container: PanelContainer = %GameContainer

@onready var gui_weather_container: GUIWeatherContainer = %GUIWeatherContainer
@onready var gui_tool_card_container: GUIToolCardContainer = %GUIToolCardContainer
@onready var gui_draw_box_button: GUIDeckButton = %GUIDrawBoxButton
@onready var gui_discard_box_button: GUIDeckButton = %GUIDiscardBoxButton
@onready var gui_exhaust_box_button: GUIDeckButton = %GUIExhaustBoxButton
@onready var gui_power_container: GUIPowerContainer = %GUIPowerContainer

@onready var gui_plant_deck_box: GUIPlantDeckBox = %GUIPlantDeckBox
@onready var gui_plant_seed_animation_container: GUIPlantSeedAnimationContainer = %GUIPlantSeedAnimationContainer

@onready var gui_shop_main: GUIShopMain = %GUIShopMain
@onready var gui_game_over_main: GUIGameOverMain = %GUIGameOverMain
@onready var gui_demo_end_main: GUIDemoEndMain = %GUIDemoEndMain
@onready var gui_library: GUILibrary = %GUILibrary
@onready var gui_thing_info_view: GUIThingInfoView = %GUIThingInfoView
@onready var gui_contract_selection_main: GUIContractSelectionMain = %GUIContractSelectionMain
@onready var gui_reward_main: GUIRewardMain = %GUIRewardMain

@onready var _gui_settings_main: GUISettingsMain = %GUISettingsMain
@onready var _gui_tool_cards_viewer: GUIToolCardsViewer = %GUIToolCardsViewer
@onready var _overlay: Control = %Overlay
@onready var _end_turn_button: GUIRichTextButton = %EndTurnButton
@onready var _gui_energy_tracker: GUIEnergyTracker = %GUIEnergyTracker
@onready var _gui_dialogue_window: GUIDialogueWindow = %GUIDialogueWindow

var _toggle_ui_semaphore := 0

func _ready() -> void:
	_gui_tool_cards_viewer.hide()
	gui_tool_card_container.tool_selected.connect(func(tool_data:ToolData) -> void: tool_selected.emit(tool_data))
	_end_turn_button.pressed.connect(func() -> void: end_turn_button_pressed.emit())
	gui_tool_card_container.setup(gui_draw_box_button, gui_discard_box_button)
	gui_top_bar.setting_button_evoked.connect(_on_settings_button_evoked)
	gui_top_bar.library_button_evoked.connect(_on_library_button_evoked)
	gui_top_bar.rating_update_finished.connect(func(value:int) -> void: rating_update_finished.emit(value))
	gui_reward_main.reward_finished.connect(func() -> void: reward_finished.emit())
	gui_plant_seed_animation_container.draw_plant_card_completed.connect(func(field_index:int, plant_data:PlantData) -> void: plant_seed_drawn_animation_completed.emit(field_index, plant_data))
	gui_shop_main.setup(gui_top_bar.gui_full_deck_button)
	gui_contract_selection_main.contract_selected.connect(func(contract_data:ContractData) -> void: contract_selected.emit(contract_data))

#region power

func bind_power_manager(power_manager:PowerManager) -> void:
	gui_power_container.bind_with_power_manager(power_manager)

#endregion

#region plants

func update_with_plants(plants:Array[PlantData]) -> void:
	gui_plant_deck_box.update_with_plants(plants)

#endregion

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
	gui_tool_card_container.toggle_all_tool_cards(toggle_on)
	if toggle_on:
		_end_turn_button.button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		_end_turn_button.button_state = GUIBasicButton.ButtonState.DISABLED

#region topbar
func update_level(level:int) -> void:
	gui_top_bar.update_level(level)

func update_gold(gold_diff:int, animated:bool) -> void:
	await gui_top_bar.update_gold(gold_diff, animated)

func bind_with_rating(rating:ResourcePoint) -> void:
	gui_top_bar.bind_with_rating(rating)

#region characters

func update_player(player_data:PlayerData) -> void:
	gui_top_bar.update_player(player_data)

#region tools
func update_tools(tool_datas:Array[ToolData]) -> void:
	gui_tool_card_container.update_tools(tool_datas)

func clear_tool_selection() -> void:
	gui_tool_card_container.clear_selection()

func bind_tool_deck(tool_deck:Deck) -> void:
	gui_draw_box_button.bind_deck(tool_deck)
	gui_discard_box_button.bind_deck(tool_deck)
	gui_exhaust_box_button.bind_deck(tool_deck)
	gui_top_bar.gui_full_deck_button.bind_deck(tool_deck)
	gui_top_bar.full_deck_button_evoked.connect(_on_deck_button_pressed.bind(tool_deck, tr("FULL_DECK_TITLE"), GUIDeckButton.Type.ALL))
	gui_draw_box_button.pressed.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_DRAW_POOL_TITLE"), gui_draw_box_button.type))
	gui_discard_box_button.pressed.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_DISCARD_POOL_TITLE"), gui_discard_box_button.type))
	gui_exhaust_box_button.pressed.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_EXHAUST_POOL_TITLE"), gui_exhaust_box_button.type))
#endregion


#region plants
func setup_plant_seed_animation_container(field_container:FieldContainer) -> void:
	gui_plant_seed_animation_container.setup(field_container, gui_plant_deck_box)

#endregion

#region days
func update_day_left(day_left:int, penalty_per_day:int) -> void:
	gui_top_bar.update_day_left(day_left, penalty_per_day)

func bind_energy(resource_point:ResourcePoint) -> void:
	_gui_energy_tracker.bind_with_resource_point(resource_point)

#region weathers
func update_weathers(weather_manager:WeatherManager) -> void:
	gui_weather_container.update_with_weather_manager(weather_manager)

#endregion

#region contract selection

func animate_show_contract_selection(contracts:Array) -> void:
	gui_contract_selection_main.animate_show_with_contracts(contracts)

#endregion

#region level summary

func animate_show_reward_main(contract_data:ContractData) -> void:
	await gui_reward_main.show_with_contract_data(contract_data)

#endregion

#region gameover

func animate_show_game_over(session_summary:SessionSummary) -> void:
	await gui_game_over_main.animate_show(session_summary)

#endregion

#region shop
func animate_show_shop(number_of_tools:int, gold:int) -> void:
	await gui_shop_main.animate_show(number_of_tools, gold)

#region utils

#region demo

func animate_show_demo_end() -> void:
	gui_demo_end_main.animate_show()

#endregion

#region control

func add_control_to_overlay(control:Control) -> void:
	_overlay.add_child(control)

func clear_all_tooltips() -> void:
	for child in _overlay.get_children():
		if child is GUITooltip:
			child.queue_free()

#endregion

#region dialog

func show_dialogue(type:GUIDialogueItem.DialogueType) -> void:
	_gui_dialogue_window.show_with_type(type)
	
func hide_dialogue(type:GUIDialogueItem.DialogueType) -> void:
	_gui_dialogue_window.hide_type(type)
	
#endregion

#region events

func _on_deck_button_pressed(deck:Deck, title:String, type: GUIDeckButton.Type) -> void:
	match type:
		GUIDeckButton.Type.DRAW:
			_gui_tool_cards_viewer.animated_show_with_pool(deck.draw_pool, title)
		GUIDeckButton.Type.DISCARD:
			_gui_tool_cards_viewer.animated_show_with_pool(deck.discard_pool, title)
		GUIDeckButton.Type.ALL:
			_gui_tool_cards_viewer.animated_show_with_pool(deck.pool, title)
		GUIDeckButton.Type.EXHAUST:
			_gui_tool_cards_viewer.animated_show_with_pool(deck.exhaust_pool, title)

func _on_settings_button_evoked() -> void:
	_gui_settings_main.animate_show()

func _on_library_button_evoked() -> void:
	gui_library.animate_show()

#endregion
