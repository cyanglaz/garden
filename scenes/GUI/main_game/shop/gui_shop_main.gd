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
@onready var _title: Label = %Title
@onready var _sub_title: Label = %SubTitle

var _display_y := 0.0
var _weak_insufficient_gold_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	_display_y = _main_panel.position.y
	_next_week_button.action_evoked.connect(_on_next_week_button_action_evoked)
	_title.text = Util.get_localized_string("SHOP_TITLE")
	_sub_title.text = Util.get_localized_string("SHOP_SUBTITLE")

func animate_show(number_of_tools:int, number_of_plants:int, gold:int) -> void:
	show()
	_populate_shop(number_of_tools, number_of_plants)
	update_for_gold(gold)
	await _play_show_animation()

func update_for_gold(gold:int) -> void:
	for gui_shop_button:GUIShopButton in seed_container.get_children():
		gui_shop_button.update_for_gold(gold)
	for gui_shop_button:GUIShopButton in tool_container.get_children():
		gui_shop_button.update_for_gold(gold)

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
		plant_shop_button.action_evoked.connect(_on_plant_shop_button_action_evoked.bind(plant_shop_button, plant_data))
		plant_shop_button.mouse_exited.connect(_on_shop_button_mouse_exited.bind())

func _populate_tools(number_of_tools) -> void:
	Util.remove_all_children(tool_container)
	var tools := MainDatabase.tool_database.roll_tools(number_of_tools)
	for tool_data:ToolData in tools:
		var tool_shop_button:GUIToolShopButton  = TOOL_SHOP_BUTTON_SCENE.instantiate()
		tool_container.add_child(tool_shop_button)
		tool_shop_button.update_with_tool_data(tool_data)
		tool_shop_button.action_evoked.connect(_on_tool_shop_button_action_evoked.bind(tool_shop_button, tool_data))
		tool_shop_button.mouse_exited.connect(_on_shop_button_mouse_exited.bind())

func _play_show_animation() -> void:
	_main_panel.position.y = HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", _display_y, SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished
	_next_week_button.show()

func animate_hide() -> void:
	_clear_insufficient_gold_tooltip()
	_next_week_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", HIDE_Y, HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _clear_insufficient_gold_tooltip() -> void:
	if _weak_insufficient_gold_tooltip.get_ref():
		_weak_insufficient_gold_tooltip.get_ref().queue_free()
		_weak_insufficient_gold_tooltip = weakref(null)

func _on_plant_shop_button_action_evoked(gui_shop_button:GUIShopButton, plant_data:PlantData) -> void:
	_clear_insufficient_gold_tooltip()
	if gui_shop_button.sufficient_gold:
		plant_shop_button_pressed.emit(plant_data)
		gui_shop_button.queue_free()
	else:
		_weak_insufficient_gold_tooltip = weakref(Util.display_warning_tooltip(tr("WARNING_INSUFFICIENT_GOLD"), gui_shop_button, false, GUITooltip.TooltipPosition.TOP))

func _on_tool_shop_button_action_evoked(gui_shop_button:GUIShopButton, tool_data:ToolData) -> void:
	_clear_insufficient_gold_tooltip()
	if gui_shop_button.sufficient_gold:
		tool_shop_button_pressed.emit(tool_data)
		gui_shop_button.queue_free()
	else:
		_weak_insufficient_gold_tooltip = weakref(Util.display_warning_tooltip(tr("WARNING_INSUFFICIENT_GOLD"), gui_shop_button, false, GUITooltip.TooltipPosition.TOP))

func _on_next_week_button_action_evoked() -> void:
	await animate_hide()
	next_week_button_pressed.emit()

func _on_shop_button_mouse_exited() -> void:
	_clear_insufficient_gold_tooltip()
