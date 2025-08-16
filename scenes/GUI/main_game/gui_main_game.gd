class_name GUIMainGame
extends CanvasLayer

signal end_turn_button_pressed()
signal tool_selected(index:int)
signal week_summary_continue_button_pressed()

@onready var gui_weather_container: GUIWeatherContainer = %GUIWeatherContainer
@onready var gui_tool_card_container: GUIToolCardContainer = %GUIToolCardContainer
@onready var gui_draw_box_button: GUIDeckButton = %GUIDrawBoxButton
@onready var gui_discard_box_button: GUIDeckButton = %GUIDiscardBoxButton
@onready var gui_plant_seed_animation_container: GUIPlantSeedAnimationContainer = %GUIPlantSeedAnimationContainer
@onready var gui_plant_draw_deck_box: GUIPlantDeckBox = %GUIPlantDrawDeckBox
@onready var gui_plant_discard_deck_box: GUIPlantDeckBox = %GUIPlantDiscardDeckBox
@onready var gui_shop_main: GUIShopMain = %GUIShopMain
@onready var gui_week_summary_main: GUIWeekSummaryMain = %GUIWeekSummaryMain

@onready var _gui_settings_main: GUISettingsMain = %GUISettingsMain
@onready var _gui_tool_cards_viewer: GUIToolCardsViewer = %GUIToolCardsViewer
@onready var _overlay: Control = %Overlay
@onready var _end_turn_button: GUIRichTextButton = %EndTurnButton
@onready var _gui_top_bar: GUITopBar = %GUITopBar
@onready var _gui_energy_tracker: GUIEnergyTracker = %GUIEnergyTracker
@onready var _gui_points: GUIPoints = %GUIPoints

func _ready() -> void:
	_gui_tool_cards_viewer.hide()
	gui_tool_card_container.tool_selected.connect(func(index:int) -> void: tool_selected.emit(index))
	_end_turn_button.action_evoked.connect(func() -> void: end_turn_button_pressed.emit())
	gui_tool_card_container.setup(gui_draw_box_button, gui_discard_box_button)
	_gui_top_bar.setting_button_evoked.connect(func() -> void: _gui_settings_main.animate_show())
	gui_week_summary_main.continue_button_pressed.connect(func() -> void: week_summary_continue_button_pressed.emit())

#region all ui
func toggle_all_ui(on:bool) -> void:
	_gui_top_bar.toggle_all_ui(on)
	gui_tool_card_container.toggle_all_tool_cards(on)
	if on:
		_end_turn_button.button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		_end_turn_button.button_state = GUIBasicButton.ButtonState.DISABLED

#region topbar
func update_week(week:int) -> void:
	_gui_top_bar.update_week(week)

func update_gold(gold:int, animated:bool) -> void:
	await _gui_top_bar.update_gold(gold, animated)

func update_points(points:int, _animated:bool) -> void:
	_gui_points.update_earned(points)

func update_points_due(points:int) -> void:
	_gui_points.update_due(points)

#region tools
func update_tools(tool_datas:Array[ToolData]) -> void:
	gui_tool_card_container.update_tools(tool_datas)

func clear_tool_selection() -> void:
	gui_tool_card_container.clear_selection()

func bind_tool_deck(tool_deck:Deck) -> void:
	gui_draw_box_button.bind_deck(tool_deck)
	gui_discard_box_button.bind_deck(tool_deck)
	_gui_top_bar.gui_full_deck_button.bind_deck(tool_deck)
	_gui_top_bar.full_deck_button_evoked.connect(_on_deck_button_pressed.bind(tool_deck, tr("FULL_DECK_TITLE"), GUIDeckButton.Type.ALL))
	gui_draw_box_button.action_evoked.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_DRAW_POOL_TITLE"), gui_draw_box_button.type))
	gui_discard_box_button.action_evoked.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_DISCARD_POOL_TITLE"), gui_discard_box_button.type))
#endregion


#region plants
func setup_plant_seed_animation_container(field_container:FieldContainer) -> void:
	gui_plant_seed_animation_container.setup(field_container, gui_plant_draw_deck_box, gui_plant_discard_deck_box)

func bind_plant_seed_deck(plant_seed_deck:Deck) -> void:
	gui_plant_draw_deck_box.bind_deck(plant_seed_deck)
	gui_plant_discard_deck_box.bind_deck(plant_seed_deck)

#endregion

#region days
func update_day(day:int) -> void:
	_gui_top_bar.update_day(day)

func bind_energy(resource_point:ResourcePoint) -> void:
	_gui_energy_tracker.bind_with_resource_point(resource_point)

#region weathers
func update_weathers(weather_manager:WeatherManager) -> void:
	gui_weather_container.update_with_weather_manager(weather_manager)

#endregion

#region week summary

func animate_show_week_summary(point:int, due:int) -> void:
	await gui_week_summary_main.animate_show(point, due)

#endregion

#region shop
func animate_show_shop(number_of_tools:int, number_of_plants:int, gold:int) -> void:
	await gui_shop_main.animate_show(number_of_tools, number_of_plants, gold)

#region utils
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

#endregion
