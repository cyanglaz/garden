class_name GUIMainGame
extends CanvasLayer

signal end_turn_button_pressed()
signal tool_selected(index:int)
signal plant_seed_selected(index:int)

@onready var gui_weather_container: GUIWeatherContainer = %GUIWeatherContainer
@onready var gui_tool_card_container: GUIToolCardContainer = %GUIToolCardContainer
@onready var gui_mouse_following_plant_icon: GUIMouseFollowingPlantIcon = %GUIMouseFollowingPlantIcon
@onready var gui_draw_box_button: GUIDeckButton = %GUIDrawBoxButton
@onready var gui_discard_box_button: GUIDeckButton = %GUIDiscardBoxButton
@onready var _gui_plant_card_container: GUIPlantCardContainer = %GUIPlantCardContainer
@onready var _overlay: Control = %Overlay
@onready var _day_label: Label = %DayLabel
@onready var _end_turn_button: GUIRichTextButton = %EndTurnButton
@onready var _gui_top_bar: GUITopBar = %GUITopBar
@onready var _gui_energy_tracker: GUIEnergyTracker = %GUIEnergyTracker

func _ready() -> void:
	gui_mouse_following_plant_icon.hide()
	gui_tool_card_container.tool_selected.connect(func(index:int) -> void: tool_selected.emit(index))
	_gui_plant_card_container.plant_selected.connect(func(index:int) -> void: plant_seed_selected.emit(index))
	_end_turn_button.action_evoked.connect(func() -> void: end_turn_button_pressed.emit())
	gui_tool_card_container.setup(gui_draw_box_button, gui_discard_box_button)
	#_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

#region all ui
func toggle_all_ui(on:bool) -> void:
	_gui_top_bar.toggle_all_ui(on)
	_gui_plant_card_container.toggle_all_plant_cards(on)
	gui_tool_card_container.toggle_all_tool_cards(on)
	if on:
		_end_turn_button.button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		_end_turn_button.button_state = GUIBasicButton.ButtonState.DISABLED

#region topbar
func update_week(week:int) -> void:
	_gui_top_bar.update_week(week)

func update_gold(gold:int, animated:bool) -> void:
	_gui_top_bar.update_gold(gold, animated)

func update_tax_due(gold:int) -> void:
	_gui_top_bar.update_tax_due(gold)

#region tools

func update_tools(tool_datas:Array[ToolData]) -> void:
	gui_tool_card_container.update_tools(tool_datas)

func clear_tool_selection() -> void:
	gui_tool_card_container.clear_selection()

func update_tool_for_energy(energy:int) -> void:
	gui_tool_card_container.update_tool_for_energy(energy)
	
#endregion


#region plants
func update_with_plant_datas(plant_datas:Array[PlantData]) -> void:
	_gui_plant_card_container.update_with_plant_datas(plant_datas)

func pin_following_plant_icon_global_position(gp:Vector2, s:Vector2) -> void:
	gui_mouse_following_plant_icon.global_position = gp
	gui_mouse_following_plant_icon.scale = s
	gui_mouse_following_plant_icon.follow_mouse = false

func unpin_following_plant_icon() -> void:
	gui_mouse_following_plant_icon.scale = Vector2.ONE
	gui_mouse_following_plant_icon.follow_mouse = true

func toggle_following_plant_icon_visibility(on:bool, plant_data:PlantData) -> void:
	if on:
		gui_mouse_following_plant_icon.follow_mouse = true
		gui_mouse_following_plant_icon.show()
		gui_mouse_following_plant_icon.update_with_plant_data(plant_data)
	else:
		gui_mouse_following_plant_icon.follow_mouse = false
		gui_mouse_following_plant_icon.hide()
		gui_mouse_following_plant_icon.update_with_plant_data(null)
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

func _on_plant_seed_selected(index:int) -> void:
	plant_seed_selected.emit(index)
