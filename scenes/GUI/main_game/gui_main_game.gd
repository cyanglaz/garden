class_name GUIMainGame
extends CanvasLayer

signal end_turn_button_pressed()
signal tool_selected(index:int)

@onready var gui_weather_container: GUIWeatherContainer = %GUIWeatherContainer
@onready var gui_tool_card_container: GUIToolCardContainer = %GUIToolCardContainer
@onready var gui_draw_box_button: GUIDeckButton = %GUIDrawBoxButton
@onready var gui_discard_box_button: GUIDeckButton = %GUIDiscardBoxButton
@onready var gui_plant_seed_animation_container: GUIPlantSeedAnimationContainer = %GUIPlantSeedAnimationContainer
@onready var gui_plant_draw_deck_button: GUIDeckButton = %GUIPlantDrawDeckButton
@onready var gui_plant_discard_deck_button: GUIDeckButton = %GUIPlantDiscardDeckButton

@onready var _overlay: Control = %Overlay
@onready var _day_label: Label = %DayLabel
@onready var _end_turn_button: GUIRichTextButton = %EndTurnButton
@onready var _gui_top_bar: GUITopBar = %GUITopBar
@onready var _gui_energy_tracker: GUIEnergyTracker = %GUIEnergyTracker

func _ready() -> void:
	gui_tool_card_container.tool_selected.connect(func(index:int) -> void: tool_selected.emit(index))
	_end_turn_button.action_evoked.connect(func() -> void: end_turn_button_pressed.emit())
	gui_tool_card_container.setup(gui_draw_box_button, gui_discard_box_button)
	#_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

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

func update_tax_due(gold:int) -> void:
	_gui_top_bar.update_tax_due(gold)

#region tools

func update_tools(tool_datas:Array[ToolData]) -> void:
	gui_tool_card_container.update_tools(tool_datas)

func clear_tool_selection() -> void:
	gui_tool_card_container.clear_selection()

func bind_tool_deck(tool_deck:Deck) -> void:
	gui_draw_box_button.bind_deck(tool_deck)
	gui_discard_box_button.bind_deck(tool_deck)
#endregion


#region plants

func setup_plant_seed_animation_container(field_container:FieldContainer) -> void:
	gui_plant_seed_animation_container.setup(field_container, gui_plant_draw_deck_button, gui_plant_discard_deck_button)

func bind_plant_seed_deck(plant_seed_deck:Deck) -> void:
	gui_plant_draw_deck_button.bind_deck(plant_seed_deck)
	gui_plant_discard_deck_button.bind_deck(plant_seed_deck)

#endregion

#region days
func set_day(day:int) -> void:
	_day_label.text = tr("DAY_LABEL_TEXT")% (day + 1)

func bind_energy(resource_point:ResourcePoint) -> void:
	_gui_energy_tracker.bind_with_resource_point(resource_point)

#region weathers
func update_weathers(weather_manager:WeatherManager) -> void:
	gui_weather_container.update_with_weather_manager(weather_manager)

#endregion

#region utils
func add_control_to_overlay(control:Control) -> void:
	_overlay.add_child(control)
#endregion
