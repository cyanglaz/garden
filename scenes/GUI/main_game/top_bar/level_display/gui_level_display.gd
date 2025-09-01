class_name GUILevelDisplay
extends HBoxContainer

const LEVEL_BUTTON_SCENE := preload("res://scenes/GUI/main_game/top_bar/level_display/gui_level_button.tscn")

func update_with_levels(levels:Array) -> void:
	Util.remove_all_children(self)
	for level_data:LevelData in levels:
		var gui_level_button: GUILevelButton = LEVEL_BUTTON_SCENE.instantiate()
		gui_level_button.action_evoked.connect(_on_level_button_action_evoked.bind(level_data))
		add_child(gui_level_button)
		gui_level_button.update_with_level_data(level_data)

func _on_level_button_action_evoked(level_data:LevelData) -> void:
	pass
