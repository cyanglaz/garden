class_name GUILevelDisplay
extends HBoxContainer

const LEVEL_BUTTON_SCENE := preload("res://scenes/GUI/main_game/top_bar/level_display/gui_level_button.tscn")

var _weak_level_tooltip:WeakRef = weakref(null)
var _tool_tip_index:int = -1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("select") || event.is_action_released("de-select"):
		if _weak_level_tooltip.get_ref():
			_weak_level_tooltip.get_ref().queue_destroy_with_tooltips()
			_weak_level_tooltip = weakref(null)
			_tool_tip_index = -1

func update_with_levels(levels:Array) -> void:
	Util.remove_all_children(self)
	var index := 0
	for level_data:LevelData in levels:
		var gui_level_button: GUILevelButton = LEVEL_BUTTON_SCENE.instantiate()
		gui_level_button.action_evoked.connect(_on_level_button_action_evoked.bind(level_data, index))
		add_child(gui_level_button)
		gui_level_button.update_with_level_data(level_data)
		index += 1

func set_current_index(index:int) -> void:
	assert(get_child_count() > 0)
	var gui_level_button: GUILevelButton = get_child(index)
	gui_level_button.icon_state = GUILevelButton.IconState.CURRENT

func _on_level_button_action_evoked(level_data:LevelData, index:int) -> void:
	if _weak_level_tooltip.get_ref():
		_weak_level_tooltip.get_ref().queue_free()
		_weak_level_tooltip = weakref(null)
	if index == _tool_tip_index:
		_tool_tip_index = -1
	else:
		_weak_level_tooltip = weakref(Util.display_level_tooltip(level_data, get_child(index), false, GUITooltip.TooltipPosition.BOTTOM_LEFT))
		_tool_tip_index = index
