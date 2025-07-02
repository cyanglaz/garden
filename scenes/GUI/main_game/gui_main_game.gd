class_name GUIMainGame
extends CanvasLayer

signal plant_seed_deselected()
signal end_turn_button_pressed()

@onready var _gui_plant_card_container: GUIPlantCardContainer = %GUIPlantCardContainer
@onready var _gui_mouse_following_plant_icon: GUIMouseFollowingPlantIcon = %GUIMouseFollowingPlantIcon
@onready var _gui_tool_card_container: GUIToolHandContainer = %GUIToolCardContainer
@onready var _overlay: Control = %Overlay
@onready var _day_label: Label = %DayLabel
@onready var _end_turn_button: GUIRichTextButton = %EndTurnButton
@onready var _time_bar: GUISegmentedProgressBar = %TimeBar
@onready var _gui_weather_container: GUIWeatherContainer = %GUIWeatherContainer
@onready var _gui_top_bar: GUITopBar = %GUITopBar

var selected_plant_seed_data:PlantData
var selected_tool_card_index:int = -1

func _ready() -> void:
	_gui_mouse_following_plant_icon.hide()
	_gui_plant_card_container.plant_selected.connect(_on_plant_seed_selected)
	_gui_tool_card_container.tool_selected.connect(_on_tool_selected)
	_end_turn_button.action_evoked.connect(func() -> void: end_turn_button_pressed.emit())
	#_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("de-select"):
		_on_plant_seed_selected(null)
		if selected_tool_card_index > -1:
			clear_tool_selection()

func _physics_process(_delta:float) -> void:
	if selected_tool_card_index != -1:
		_gui_tool_card_container.show_tool_indicator(selected_tool_card_index)		

#region all ui
func toggle_all_ui(on:bool) -> void:
	_gui_top_bar.toggle_all_ui(on)
	_gui_plant_card_container.toggle_all_plant_cards(on)
	_gui_tool_card_container.toggle_all_tool_cards(on)
	if on:
		_end_turn_button.button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		_end_turn_button.button_state = GUIBasicButton.ButtonState.DISABLED

#region topbar
func update_week(week:int) -> void:
	_gui_top_bar.update_week(week)

func update_gold(gold:int, animated:bool) -> void:
	_gui_top_bar.update_gold(gold, animated)

#region tools
func setup_tools(tool_datas:Array[ToolData]) -> void:
	_gui_tool_card_container.setup_with_tool_datas(tool_datas)

func update_tools(tool_datas:Array[ToolData]) -> void:
	_gui_tool_card_container.update_tools(tool_datas)

func clear_tool_selection() -> void:
	_gui_tool_card_container.clear_selection()
	selected_tool_card_index = -1

func update_tool_for_time(time_tracker:ResourcePoint) -> void:
	_gui_tool_card_container.update_tool_for_time_left(time_tracker.max_value - time_tracker.value)
	
#endregion

#region plants
func update_with_plant_datas(plant_datas:Array[PlantData]) -> void:
	_gui_plant_card_container.update_with_plant_datas(plant_datas)

func pin_following_plant_icon_global_position(gp:Vector2, s:Vector2) -> void:
	_gui_mouse_following_plant_icon.global_position = gp
	_gui_mouse_following_plant_icon.scale = s
	_gui_mouse_following_plant_icon.follow_mouse = false

func unpin_following_plant_icon() -> void:
	_gui_mouse_following_plant_icon.scale = Vector2.ONE
	_gui_mouse_following_plant_icon.follow_mouse = true
#endregion

#region days
func set_day(turn:int) -> void:
	_day_label.text = tr("DAY_LABEL_TEXT")% turn

func bind_time(resource_point:ResourcePoint) -> void:
	_time_bar.bind_with_resource_point(resource_point)

#region weathers
func update_weathers(weather_manager:WeatherManager, day:int) -> void:
	_gui_weather_container.update_with_weather_manager(weather_manager, day)
#endregion

#region utils
func add_control_to_overlay(control:Control) -> void:
	_overlay.add_child(control)
#endregion

func _toggle_following_plant_icon_visibility(on:bool) -> void:
	if on:
		_gui_mouse_following_plant_icon.follow_mouse = true
		_gui_mouse_following_plant_icon.show()
	else:
		_gui_mouse_following_plant_icon.follow_mouse = false
		_gui_mouse_following_plant_icon.hide()

func _on_plant_seed_selected(plant_data:PlantData) -> void:
	selected_plant_seed_data = plant_data
	_toggle_following_plant_icon_visibility(selected_plant_seed_data != null)
	if selected_plant_seed_data:
		clear_tool_selection()
		_gui_mouse_following_plant_icon.update_with_plant_data(selected_plant_seed_data)
	else:
		plant_seed_deselected.emit()
		_gui_mouse_following_plant_icon.update_with_plant_data(null)

func _on_tool_selected(index:int, _tool_data:ToolData) -> void:
	selected_tool_card_index = index
	if selected_tool_card_index > -1:
		_on_plant_seed_selected(null)
