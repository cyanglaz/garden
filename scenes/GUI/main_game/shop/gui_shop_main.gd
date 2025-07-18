class_name GUIShopMain
extends Control

const HIDE_Y := 200
const SHOW_ANIMATION_DURATION := 0.15
const HIDE_ANIMATION_DURATION := 0.15

signal plant_shop_button_pressed(plant_data:PlantData)
signal tool_shop_button_pressed(tool_data:ToolData)
signal next_week_button_pressed()

const PLANT_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/main_game/shop/shop_buttons/gui_plant_shop_button.tscn")
const TOOL_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/main_game/shop/shop_buttons/gui_tool_shop_button.tscn")

@onready var seed_container: GridContainer = %SeedContainer
@onready var tool_container: HBoxContainer = %ToolContainer
@onready var _main_panel: PanelContainer = $MainPanel
@onready var _next_week_button: GUIRichTextButton = %NextWeekButton

var _display_y := 0.0

func _ready() -> void:
	_display_y = _main_panel.position.y
	_next_week_button.action_evoked.connect(_on_next_week_button_action_evoked)

func animate_show(number_of_tools:int, number_of_plants:int) -> void:
	show()
	_populate_shop(number_of_tools, number_of_plants)
	await _play_show_animation()

func _populate_shop(number_of_tools:int, number_of_plants:int) -> void:
	_populate_tools(number_of_tools)
	_populate_plants(number_of_plants)

func _populate_plants(number_of_plants) -> void:
	Util.remove_all_children(seed_container)
	var plants := MainDatabase.plant_database.roll_plants(number_of_plants)
	for plant_data:PlantData in plants:	
		var plant_shop_button:GUIPlantShopButton = PLANT_SHOP_BUTTON_SCENE.instantiate()
		seed_container.add_child(plant_shop_button)
		plant_shop_button.update_with_plant_data(plant_data)
		plant_shop_button.action_evoked.connect(_on_plant_shop_button_action_evoked.bind(plant_data))

func _populate_tools(number_of_tools) -> void:
	Util.remove_all_children(tool_container)
	var tools := MainDatabase.tool_database.roll_tools(number_of_tools)
	for tool_data:ToolData in tools:
		var tool_shop_button:GUIToolShopButton  = TOOL_SHOP_BUTTON_SCENE.instantiate()
		tool_container.add_child(tool_shop_button)
		tool_shop_button.update_with_tool_data(tool_data)
		tool_shop_button.action_evoked.connect(_on_tool_shop_button_action_evoked.bind(tool_data))

func _play_show_animation() -> void:
	_main_panel.position.y = HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", _display_y, SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished
	_next_week_button.show()

func animate_hide() -> void:
	_next_week_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", HIDE_Y, HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _on_plant_shop_button_action_evoked(plant_data:PlantData) -> void:
	plant_shop_button_pressed.emit(plant_data)

func _on_tool_shop_button_action_evoked(tool_data:ToolData) -> void:
	tool_shop_button_pressed.emit(tool_data)

func _on_next_week_button_action_evoked() -> void:
	await animate_hide()
	next_week_button_pressed.emit()
