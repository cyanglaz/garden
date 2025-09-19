class_name GUIDialogueWindow
extends PanelContainer

const DIALOGUE_ITEM_SCENE := preload("res://scenes/GUI/main_game/dialog/gui_dialogue_item.tscn")

@onready var v_box_container: VBoxContainer = %VBoxContainer

func show_with_type(type:GUIDialogueItem.DialogueType) -> void:
	for child:GUIDialogueItem in v_box_container.get_children():
		if child.dialogue_type == type:
			return
	var item:GUIDialogueItem = DIALOGUE_ITEM_SCENE.instantiate()
	v_box_container.add_child(item)
	item.show_with_type(type)
	_reorder_children()

func hide_type(type:GUIDialogueItem.DialogueType) -> void:
	for child:GUIDialogueItem in v_box_container.get_children():
		if child.dialogue_type == type:
			v_box_container.remove_child(child)
			child.queue_free()
			return
	_reorder_children()

func _reorder_children() -> void:
	for index:int in v_box_container.get_child_count():
		var child_item:GUIDialogueItem = v_box_container.get_child(index)
		if index == 0:
			child_item.is_top_item = true
		else:
			child_item.is_top_item = false
