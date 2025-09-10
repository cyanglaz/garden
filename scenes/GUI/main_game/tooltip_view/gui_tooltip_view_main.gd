class_name GUITooltipViewMain
extends Control

const PLANT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")
const CARd_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_card_tooltip.tscn")

@onready var title_label: Label = %TitleLabel
@onready var sub_title_label: Label = %SubTitleLabel
@onready var tooltip_container: HBoxContainer = %TooltipContainer

var tooltip_data_stack:Array[Resource] = []

func _ready() -> void:
	title_label.text = Util.get_localized_string("INFO_TITLE")
	sub_title_label.text = ""
	update_with_plant_data(MainDatabase.plant_database.get_data_by_id("rose"))

func update_with_plant_data(plant_data:PlantData) -> void:
	var plant_tooltip:GUIPlantTooltip = PLANT_TOOLTIP_SCENE.instantiate()
	tooltip_container.add_child(plant_tooltip)
	plant_tooltip.update_with_plant_data(plant_data)
	plant_tooltip.mouse_default_cursor_shape = Control.CursorShape.CURSOR_POINTING_HAND
	plant_tooltip.gui_input.connect(_on_tooltip_pressed.bind(plant_data))
	# Find secondary tooltips (ToolData)
	var tool_ids:Array[String] = Util.find_tool_ids_in_data(plant_data.data)
	for tool_id:String in tool_ids:
		var tool_data := MainDatabase.tool_database.get_data_by_id(tool_id)
		update_with_tool_data(tool_data)

func update_with_tool_data(tool_data:ToolData) -> void:
	var tool_tooltip:GUICardTooltip = CARd_TOOLTIP_SCENE.instantiate()
	tooltip_container.add_child(tool_tooltip)
	tool_tooltip.update_with_tool_data(tool_data)
	tool_tooltip.gui_input.connect(_on_tooltip_pressed.bind(tool_data))
	tool_tooltip.mouse_default_cursor_shape = Control.CursorShape.CURSOR_POINTING_HAND

func _on_tooltip_pressed(event: InputEvent, data:Resource) -> void:
	if !event.is_action_pressed("select"):
		return
	tooltip_data_stack.append(data)
	Util.remove_all_children(tooltip_container)
	if data is PlantData:
		update_with_plant_data(data)
	elif data is ToolData:
		update_with_tool_data(data)
