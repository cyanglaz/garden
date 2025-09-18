class_name GUILibrary
extends Control

const LIBRARY_SCENE := preload("res://scenes/GUI/main_game/library/gui_library_item.tscn")

@onready var _main_panel: PanelContainer = %MainPanel
@onready var _title_label: Label = %TitleLabel
@onready var _gui_library_tabbar: GUILibraryTabbar = %GUILibararyTabbar
@onready var _back_button: GUIRichTextButton = %BackButton
@onready var _browsing_scroll_container: ScrollContainer = %BrowsingScrollContainer
@onready var _browsing_container: GridContainer = %BrowsingContainer
@onready var _tooltip_scroll_container: ScrollContainer = %TooltipScrollContainer
@onready var _tooltip_container: HBoxContainer = %TooltipContainer
@onready var _gui_library_left_bar: GUILibraryLeftBar = %GUILibraryLeftBar

var tooltip_data_stacks:Dictionary = {}
var _display_y := 0.0

func _ready() -> void:
	_display_y = _main_panel.position.y
	_title_label.text = Util.get_localized_string("INFO_TITLE")
	_gui_library_tabbar.tab_evoked.connect(_on_tab_evoked)
	_gui_library_tabbar.all_tabs_cleared.connect(_on_all_tabs_cleared)
	_gui_library_tabbar.tab_removed.connect(_on_tab_removed)
	_back_button.pressed.connect(_on_back_button_evoked)
	_back_button.hide()
	_gui_library_left_bar.button_pressed.connect(_on_left_bar_button_pressed)
	#animate_show(MainDatabase.plant_database.get_data_by_id("rose"))

func animate_show(data:Resource) -> void:
	if Singletons.main_game:
		Singletons.main_game.clear_all_tooltips()
	PauseManager.try_pause()
	show()
	_tooltip_scroll_container.hide()
	_browsing_scroll_container.hide()
	if data:
		update_with_data(data, 0)
	else:
		update_with_category("card")
	await _play_show_animation()

func update_with_category(category:String) -> void:
	_browsing_scroll_container.show()
	_list_items(category)

func update_with_data(data:Resource, index_level:int) -> void:
	_tooltip_scroll_container.show()
	_browsing_scroll_container.hide()
	_title_label.text = Util.get_localized_string("INFO_TITLE")
	if data == null:
		return
	_clear_tooltips(index_level)
	var selected_id := ""
	if index_level > 0:
		selected_id = _gui_library_tabbar.datas[_gui_library_tabbar.selected_index].id
		if tooltip_data_stacks[selected_id].size() <= index_level:
			tooltip_data_stacks[selected_id].append(data)
		elif tooltip_data_stacks[selected_id][index_level].id != data.id:
			tooltip_data_stacks[selected_id][index_level] = data
	else:
		if !tooltip_data_stacks.has(data.id):
			tooltip_data_stacks[data.id] = [data]
			_gui_library_tabbar.add_top_bar_button(data)
		selected_id = data.id
	var stack:Array = tooltip_data_stacks[selected_id]
	for i:int in stack.size():
		if i < index_level:
			continue
		var data_to_show:ThingData = stack[i]
		var next_level_id:String = ""
		if i + 1 < stack.size():
			next_level_id = stack[i + 1].id
		if data_to_show is PlantData:
			_update_with_plant_data(data_to_show, i, next_level_id)
		elif data_to_show is ToolData:
			_update_with_tool_data(data_to_show, i, next_level_id)
		elif data_to_show is LevelData:
			_update_with_level_data(data_to_show, i, next_level_id)
		elif data_to_show is FieldStatusData || data_to_show is PowerData:
			_update_with_thing_data(data_to_show, i, next_level_id)
	var index:int = Util.array_find(_gui_library_tabbar.datas, func(d:ThingData): return d.id == selected_id)
	_gui_library_tabbar.select_button(index)

#region showing category

func _list_items(category:String) -> void:
	var data_list:Array = []
	match category:
		"card":
			_browsing_container.columns = 4
			data_list = MainDatabase.tool_database.get_all_datas()
		"plant":
			_browsing_container.columns = 4
			data_list = MainDatabase.plant_database.get_all_datas()
		"misc":
			_browsing_container.columns = 6
			data_list = MainDatabase.field_status_database.get_all_datas()
			data_list.append_array(MainDatabase.power_database.get_all_datas())
		"boss":
			_browsing_container.columns = 4
			data_list = MainDatabase.level_database.get_all_datas()
	for data:ThingData in data_list:
		var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
		_browsing_container.add_child(item)
		if data is PlantData:
			item.update_with_plant_data(data, -1, "")
		elif data is ToolData:
			item.update_with_tool_data(data, -1, "")
		elif data is FieldStatusData:
			item.update_with_field_status_data(data, -1, "")
		elif data is PowerData:
			item.update_with_power_data(data, -1, "")
		elif data is LevelData:
			item.update_with_level_data(data, -1, "")
		elif data is ThingData:
			item.update_with_thing_data(data, -1, "")


#endregion

#region showing items

func _update_with_plant_data(plant_data:PlantData, level_index:int, next_level_id:String) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_plant_data(plant_data, level_index, next_level_id)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _update_with_tool_data(tool_data:ToolData, level_index:int, next_level_id:String) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_tool_data(tool_data, level_index, next_level_id)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _update_with_level_data(level_data:LevelData, level_index:int, next_level_id:String) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_level_data(level_data, level_index, next_level_id)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _update_with_thing_data(thing_data:ThingData, level_index:int, next_level_id:String) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_thing_data(thing_data, level_index, next_level_id)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _clear_tooltips(from_level:int) -> void:
	for i in _tooltip_container.get_child_count():
		if i >= from_level:
			_tooltip_container.get_child(i).queue_free()

#endregion

func _play_show_animation() -> void:
	_main_panel.position.y = Constants.PENEL_HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", _display_y, Constants.SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished
	_back_button.show()

func animate_hide() -> void:
	_back_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", Constants.PENEL_HIDE_Y, Constants.HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
	PauseManager.try_unpause()

func _on_reference_button_evoked(reference_pair:Array, level:int) -> void:
	var data:Resource
	if reference_pair[0] == "plant":
		data = MainDatabase.plant_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "card":
		data = MainDatabase.tool_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "level":
		data = MainDatabase.level_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "field_status":
		data = MainDatabase.field_status_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "power":
		data = MainDatabase.power_database.get_data_by_id(reference_pair[1])
	update_with_data(data, level + 1)

func _on_tooltip_button_evoked(data:Resource) -> void:
	update_with_data(data, 0)

func _on_tab_evoked(data:ThingData) -> void:
	update_with_data(data, 0)

func _on_tab_removed(id:String) -> void:
	tooltip_data_stacks.erase(id)

func _on_all_tabs_cleared() -> void:
	Util.remove_all_children(_tooltip_container)
	tooltip_data_stacks.clear()

func _on_left_bar_button_pressed(category:String) -> void:
	update_with_category(category)

func _on_back_button_evoked() -> void:
	animate_hide()
	_gui_library_tabbar.clear_all_tabs()
	Util.remove_all_children(_tooltip_container)
