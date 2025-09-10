class_name GUILibrary
extends Control

const PLANT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")
const CARD_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_card_tooltip.tscn")
const TOOL_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_tool_card_tooltip.tscn")
const BOSS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_boss_tooltip.tscn")

const LIBRARY_SCENE := preload("res://scenes/GUI/main_game/library/gui_library_item.tscn")

@onready var title_label: Label = %TitleLabel
@onready var tooltip_container: HBoxContainer = %TooltipContainer
@onready var gui_library_tabbar: GUILibraryTabbar = %GUILibararyTabbar
@onready var gui_close_button: GUICloseButton = %GUICloseButton

var tooltip_data_stack:Array[Resource] = []

func _ready() -> void:
	gui_close_button.hide()
	title_label.text = Util.get_localized_string("INFO_TITLE")
	gui_library_tabbar.tab_evoked.connect(_on_tab_evoked)
	gui_library_tabbar.all_tabs_cleared.connect(_on_all_tabs_cleared)
	gui_close_button.action_evoked.connect(_on_close_button_evoked)
	
	update_with_data(MainDatabase.plant_database.get_data_by_id("rose"))

func update_with_data(data:Resource) -> void:
	Util.remove_all_children(tooltip_container)
	if data == null:
		return
	var index:int = Util.array_find(gui_library_tabbar.datas, func(d:ThingData): return d.id == data.id)
	if index == -1:
		gui_library_tabbar.add_top_bar_button(data)
	else:
		gui_library_tabbar.select_button(index)
	if data is PlantData:
		_update_with_plant_data(data)
	elif data is ToolData:
		_update_with_tool_data(data)
	elif data is LevelData:
		_update_with_level_data(data)
	elif data is FieldStatusData:
		_update_with_field_status_data(data)
	gui_close_button.show()

func _update_with_plant_data(plant_data:PlantData) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	tooltip_container.add_child(item)
	item.update_with_plant_data(plant_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(tooltip_container.get_child_count() -1))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _update_with_tool_data(tool_data:ToolData) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	tooltip_container.add_child(item)
	item.update_with_tool_data(tool_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(tooltip_container.get_child_count() -1))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _update_with_level_data(level_data:LevelData) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	tooltip_container.add_child(item)
	item.update_with_level_data(level_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(tooltip_container.get_child_count() -1))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _update_with_field_status_data(field_status_data:FieldStatusData) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	tooltip_container.add_child(item)
	item.update_with_field_status_data(field_status_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(tooltip_container.get_child_count() -1))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _clear_tooltips(from_level:int) -> void:
	for i in tooltip_container.get_child_count():
		if i >= from_level:
			tooltip_container.get_child(i).queue_free()

func _on_reference_button_evoked(reference_pair:Array, level:int) -> void:
	_clear_tooltips(level + 1)
	var data:Resource
	if reference_pair[0] == "plant":
		data = MainDatabase.plant_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "card":
		data = MainDatabase.tool_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "level":
		data = MainDatabase.level_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "field_status":
		data = MainDatabase.field_status_database.get_data_by_id(reference_pair[1])
	update_with_data(data)

func _on_tooltip_button_evoked(data:Resource) -> void:
	Util.remove_all_children(tooltip_container)
	update_with_data(data)

func _on_tab_evoked(data:ThingData) -> void:
	update_with_data(data)

func _on_close_button_evoked() -> void:
	gui_library_tabbar.remove_tab(gui_library_tabbar.selected_index)

func _on_all_tabs_cleared() -> void:
	Util.remove_all_children(tooltip_container)
	gui_close_button.hide()
