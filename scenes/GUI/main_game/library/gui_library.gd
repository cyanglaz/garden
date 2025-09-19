class_name GUILibrary
extends Control

const LIBRARY_ICON_SCENE := preload("res://scenes/GUI/main_game/library/gui_library_icon.tscn")

const CARD_PER_ROW := 4
const PLANT_PER_ROW := 8
const MISC_PER_ROW := 12
const BOSS_PER_ROW := 8

@onready var _main_panel: PanelContainer = %MainPanel
@onready var _title_label: Label = %TitleLabel
@onready var _back_button: GUIRichTextButton = %BackButton
@onready var _browsing_container: GridContainer = %BrowsingContainer
@onready var _gui_library_left_bar: GUILibraryLeftBar = %GUILibraryLeftBar

var _display_y := 0.0

func _ready() -> void:
	_display_y = _main_panel.position.y
	_title_label.text = Util.get_localized_string("INFO_TITLE")
	_back_button.pressed.connect(_on_back_button_evoked)
	_back_button.hide()
	_gui_library_left_bar.button_pressed.connect(_on_left_bar_button_pressed)
	#animate_show(MainDatabase.plant_database.get_data_by_id("rose"))

func animate_show() -> void:
	if Singletons.main_game:
		Singletons.main_game.clear_all_tooltips()
	PauseManager.try_pause()
	show()
	update_with_category("card")
	await _play_show_animation()

func update_with_category(category:String) -> void:
	_list_items(category)

#region showing category

func _list_items(category:String) -> void:
	Util.remove_all_children(_browsing_container)
	var data_list:Array = []
	match category:
		"card":
			_browsing_container.columns = CARD_PER_ROW
			data_list = MainDatabase.tool_database.get_all_datas()
		"plant":
			_browsing_container.columns = PLANT_PER_ROW
			data_list = MainDatabase.plant_database.get_all_datas()
		"misc":
			_browsing_container.columns = MISC_PER_ROW
			data_list = MainDatabase.field_status_database.get_all_datas()
			data_list.append_array(MainDatabase.power_database.get_all_datas())
		"boss":
			_browsing_container.columns = BOSS_PER_ROW
			data_list = MainDatabase.level_database.get_all_datas()
	for data:ThingData in data_list:
		if data is LevelData && data.type != LevelData.Type.BOSS:
			continue
		var icon:GUILibraryIcon = LIBRARY_ICON_SCENE.instantiate()
		_browsing_container.add_child(icon)
		if data is PlantData:
			icon.update_with_plant_data(data)
		elif data is ToolData:
			icon.update_with_tool_data(data)
		elif data is LevelData:
			icon.update_with_level_data(data)
		elif data is FieldStatusData:
			icon.update_with_field_status_data(data)
		elif data is PowerData:
			icon.update_with_power_data(data)
		icon.button_evoked.connect(_on_icon_button_evoked)

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
	Util.remove_all_children(_browsing_container)
	PauseManager.try_unpause()

func _on_left_bar_button_pressed(category:String) -> void:
	update_with_category(category)

func _on_back_button_evoked() -> void:
	animate_hide()

func _on_icon_button_evoked(data:Resource) -> void:
	Singletons.main_game.show_thing_info_view(data)
