class_name GUILibraryItemWrapperButton
extends GUIBasicButton

@onready var margin_container: MarginContainer = %MarginContainer

func add_item(item:Control) -> void:
	margin_container.add_child(item)
