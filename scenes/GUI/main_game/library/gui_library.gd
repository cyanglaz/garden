class_name GUILibrary
extends Control

const LIBRARY_SCENE := preload("res://scenes/GUI/main_game/library/gui_library_item.tscn")

@onready var _main_panel: PanelContainer = %MainPanel
@onready var _title_label: Label = %TitleLabel
@onready var _tooltip_container: HBoxContainer = %TooltipContainer
@onready var _gui_library_tabbar: GUILibraryTabbar = %GUILibararyTabbar
@onready var _back_button: GUIRichTextButton = %BackButton

var tooltip_data_stack:Array[Resource] = []
var _display_y := 0.0

func _ready() -> void:
	_display_y = _main_panel.position.y
	_title_label.text = Util.get_localized_string("INFO_TITLE")
	_gui_library_tabbar.tab_evoked.connect(_on_tab_evoked)
	_gui_library_tabbar.all_tabs_cleared.connect(_on_all_tabs_cleared)
	_back_button.action_evoked.connect(_on_back_button_evoked)
	_back_button.hide()
	animate_show(MainDatabase.plant_database.get_data_by_id("rose"))

func animate_show(data:Resource) -> void:
	if Singletons.main_game:
		Singletons.main_game.clear_all_tooltips()
	PauseManager.try_pause()
	show()
	update_with_data(data)
	await _play_show_animation()

func update_with_data(data:Resource) -> void:
	_title_label.text = Util.get_localized_string("INFO_TITLE")
	Util.remove_all_children(_tooltip_container)
	if data == null:
		return
	var index:int = Util.array_find(_gui_library_tabbar.datas, func(d:ThingData): return d.id == data.id)
	if index == -1:
		_gui_library_tabbar.add_top_bar_button(data)
	else:
		_gui_library_tabbar.select_button(index)
	if data is PlantData:
		_update_with_plant_data(data)
	elif data is ToolData:
		_update_with_tool_data(data)
	elif data is LevelData:
		_update_with_level_data(data)
	elif data is FieldStatusData:
		_update_with_field_status_data(data)

func _update_with_plant_data(plant_data:PlantData) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_plant_data(plant_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(_tooltip_container.get_child_count() -1))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _update_with_tool_data(tool_data:ToolData) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_tool_data(tool_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(_tooltip_container.get_child_count() -1))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _update_with_level_data(level_data:LevelData) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_level_data(level_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(_tooltip_container.get_child_count() -1))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _update_with_field_status_data(field_status_data:FieldStatusData) -> void:
	var item:GUILibraryItem = LIBRARY_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_field_status_data(field_status_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(_tooltip_container.get_child_count() -1))
	item.tooltip_button_evoked.connect(_on_tooltip_button_evoked)

func _clear_tooltips(from_level:int) -> void:
	for i in _tooltip_container.get_child_count():
		if i >= from_level:
			_tooltip_container.get_child(i).queue_free()

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
	Util.remove_all_children(_tooltip_container)
	update_with_data(data)

func _on_tab_evoked(data:ThingData) -> void:
	update_with_data(data)

func _on_all_tabs_cleared() -> void:
	Util.remove_all_children(_tooltip_container)

func _on_back_button_evoked() -> void:
	animate_hide()
	_gui_library_tabbar.clear_all_tabs()
