class_name GUIMainGame
extends CanvasLayer

signal plant_seed_deselected()

@onready var _gui_weather: GUIWeather = %GUIWeather
@onready var _gui_plant_card_container: GUIPlantCardContainer = %GUIPlantCardContainer
@onready var _gui_mouse_following_plant_icon: GUIMouseFollowingPlantIcon = %GUIMouseFollowingPlantIcon
@onready var _gui_tool_card_container: GUIToolHandContainer = %GUIToolCardContainer
@onready var _overlay: Control = %Overlay

var selected_plant_seed_data:PlantData
var _selected_tool_card_index:int = -1

func _ready() -> void:
	_gui_mouse_following_plant_icon.hide()
	_gui_plant_card_container.plant_selected.connect(_on_plant_seed_selected)
	_gui_tool_card_container.tool_selected.connect(_on_tool_selected)
	#_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("de-select"):
		_on_plant_seed_selected(null)
		_gui_tool_card_container.clear_selection()
		_selected_tool_card_index = -1

func _physics_process(_delta:float) -> void:
	if _selected_tool_card_index != -1:
		_gui_tool_card_container.show_tool_indicator(_selected_tool_card_index)		

func update_with_tool_datas(tool_datas:Array[ToolData]) -> void:
	_gui_tool_card_container.update_with_tool_datas(tool_datas)
	
func update_with_plant_datas(plant_datas:Array[PlantData]) -> void:
	_gui_plant_card_container.update_with_plant_datas(plant_datas)

func pin_following_plant_icon_global_position(gp:Vector2, s:Vector2) -> void:
	_gui_mouse_following_plant_icon.global_position = gp
	_gui_mouse_following_plant_icon.scale = s
	_gui_mouse_following_plant_icon.follow_mouse = false

func unpin_following_plant_icon() -> void:
	_gui_mouse_following_plant_icon.scale = Vector2.ONE
	_gui_mouse_following_plant_icon.follow_mouse = true

func add_control_to_overlay(control:Control) -> void:
	_overlay.add_child(control)

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
		_gui_mouse_following_plant_icon.update_with_plant_data(selected_plant_seed_data)
	else:
		plant_seed_deselected.emit()
		_gui_mouse_following_plant_icon.update_with_plant_data(null)

func _on_tool_selected(index:int, _tool_data:ToolData) -> void:
	_selected_tool_card_index = index
