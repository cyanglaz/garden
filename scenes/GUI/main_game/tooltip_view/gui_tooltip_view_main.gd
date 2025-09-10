class_name GUITooltipViewMain
extends Control

const PLANT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")
const CARD_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_card_tooltip.tscn")
const TOOL_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_tool_card_tooltip.tscn")
const BOSS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_boss_tooltip.tscn")

const COLUMN_SCENE := preload("res://scenes/GUI/main_game/tooltip_view/gui_tooltip_view_column.tscn")

@onready var title_label: Label = %TitleLabel
@onready var sub_title_label: Label = %SubTitleLabel
@onready var tooltip_container: HBoxContainer = %TooltipContainer

var tooltip_data_stack:Array[Resource] = []

func _ready() -> void:
	title_label.text = Util.get_localized_string("INFO_TITLE")
	sub_title_label.text = ""
	update_with_level_data(MainDatabase.level_database.get_data_by_id("lady_rose"))

func update_with_plant_data(plant_data:PlantData) -> void:
	var column:GUITooltipViewColumn = COLUMN_SCENE.instantiate()
	tooltip_container.add_child(column)
	column.update_with_plant_data(plant_data)
	column.reference_button_evoked.connect(_on_reference_button_evoked.bind(tooltip_container.get_child_count() -1))
	column.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func update_with_tool_data(tool_data:ToolData) -> void:
	var column:GUITooltipViewColumn = COLUMN_SCENE.instantiate()
	tooltip_container.add_child(column)
	column.update_with_tool_data(tool_data)
	column.reference_button_evoked.connect(_on_reference_button_evoked.bind(tooltip_container.get_child_count() -1))
	column.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func update_with_level_data(level_data:LevelData) -> void:
	var column:GUITooltipViewColumn = COLUMN_SCENE.instantiate()
	tooltip_container.add_child(column)
	column.update_with_level_data(level_data)
	column.reference_button_evoked.connect(_on_reference_button_evoked.bind(tooltip_container.get_child_count() -1))
	column.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _clear_tooltips(from_level:int) -> void:
	for i in tooltip_container.get_child_count():
		if i >= from_level:
			tooltip_container.get_child(i).queue_free()
func _on_reference_button_evoked(reference_pair:Array, level:int) -> void:
	_clear_tooltips(level + 1)
	if reference_pair[0] == "plant":
		update_with_plant_data(MainDatabase.plant_database.get_data_by_id(reference_pair[1]))
	elif reference_pair[0] == "card":
		update_with_tool_data(MainDatabase.tool_database.get_data_by_id(reference_pair[1]))
	elif reference_pair[0] == "level":
		update_with_level_data(MainDatabase.level_database.get_data_by_id(reference_pair[1]))

func _on_tooltip_button_evoked(data:Resource) -> void:
	tooltip_data_stack.append(data)
	Util.remove_all_children(tooltip_container)
	if data is PlantData:
		update_with_plant_data(data)
	elif data is ToolData:
		update_with_tool_data(data)
	elif data is LevelData:
		update_with_level_data(data)
