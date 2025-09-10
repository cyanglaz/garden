class_name GUIMainGame
extends CanvasLayer

signal end_turn_button_pressed()
signal tool_selected(tool_data:ToolData)
signal level_summary_continue_button_pressed()
signal gold_increased(gold:int)
signal plant_seed_drawn_animation_completed(field_index:int, plant_data:PlantData)

@onready var gui_top_bar: GUITopBar = %GUITopBar
@onready var game_container: PanelContainer = %GameContainer

@onready var gui_weather_container: GUIWeatherContainer = %GUIWeatherContainer
@onready var gui_tool_card_container: GUIToolCardContainer = %GUIToolCardContainer
@onready var gui_draw_box_button: GUIDeckButton = %GUIDrawBoxButton
@onready var gui_discard_box_button: GUIDeckButton = %GUIDiscardBoxButton
@onready var gui_exhaust_box_button: GUIDeckButton = %GUIExhaustBoxButton

@onready var gui_plant_deck_box: GUIPlantDeckBox = %GUIPlantDeckBox
@onready var gui_plant_seed_animation_container: GUIPlantSeedAnimationContainer = %GUIPlantSeedAnimationContainer

@onready var gui_shop_main: GUIShopMain = %GUIShopMain
@onready var gui_level_summary_main: GUILevelSummaryMain = %GUILevelSummaryMain
@onready var gui_game_over_main: GUIGameOverMain = %GUIGameOverMain
@onready var gui_demo_end_main: GUIDemoEndMain = %GUIDemoEndMain
@onready var gui_enemy: GUIEnemy = %GUIEnemy



@onready var _gui_settings_main: GUISettingsMain = %GUISettingsMain
@onready var _gui_tool_cards_viewer: GUIToolCardsViewer = %GUIToolCardsViewer
@onready var _overlay: Control = %Overlay
@onready var _end_turn_button: GUIRichTextButton = %EndTurnButton
@onready var _gui_energy_tracker: GUIEnergyTracker = %GUIEnergyTracker

var _toggle_ui_semaphore := 0

func _ready() -> void:
	_gui_tool_cards_viewer.hide()
	gui_tool_card_container.tool_selected.connect(func(tool_data:ToolData) -> void: tool_selected.emit(tool_data))
	_end_turn_button.action_evoked.connect(func() -> void: end_turn_button_pressed.emit())
	gui_tool_card_container.setup(gui_draw_box_button, gui_discard_box_button)
	gui_top_bar.setting_button_evoked.connect(_on_settings_button_evoked)
	gui_level_summary_main.continue_button_pressed.connect(func() -> void: level_summary_continue_button_pressed.emit())
	gui_level_summary_main.gold_increased.connect(func(gold:int) -> void: gold_increased.emit(gold))
	gui_plant_seed_animation_container.draw_plant_card_completed.connect(func(field_index:int, plant_data:PlantData) -> void: plant_seed_drawn_animation_completed.emit(field_index, plant_data))
	gui_shop_main.setup(gui_top_bar.gui_full_deck_button)

#region level

func update_levels(level_manager:LevelManager) -> void:
	gui_top_bar.update_levels(level_manager.levels)
	gui_top_bar.update_level(level_manager.level_index)
	gui_enemy.update_with_level_data(level_manager.current_level)

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

func update_gold(gold:int, animated:bool) -> void:
	await gui_top_bar.update_gold(gold, animated)

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
	gui_draw_box_button.action_evoked.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_DRAW_POOL_TITLE"), gui_draw_box_button.type))
	gui_discard_box_button.action_evoked.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_DISCARD_POOL_TITLE"), gui_discard_box_button.type))
	gui_exhaust_box_button.action_evoked.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_EXHAUST_POOL_TITLE"), gui_exhaust_box_button.type))
#endregion


#region plants
func setup_plant_seed_animation_container(field_container:FieldContainer) -> void:
	gui_plant_seed_animation_container.setup(field_container, gui_plant_deck_box)

#endregion

#region days
func update_day_left(day_left:int) -> void:
	gui_top_bar.update_day_left(day_left)

func bind_energy(resource_point:ResourcePoint) -> void:
	_gui_energy_tracker.bind_with_resource_point(resource_point)

#region weathers
func update_weathers(weather_manager:WeatherManager) -> void:
	gui_weather_container.update_with_weather_manager(weather_manager)

#endregion

#region level summary

func animate_show_level_summary(days_left:int) -> void:
	await gui_level_summary_main.animate_show(days_left)

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

#endregion
