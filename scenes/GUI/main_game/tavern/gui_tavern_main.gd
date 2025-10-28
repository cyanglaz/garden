class_name GUITavernMain
extends CanvasLayer

const EVENT_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_event_selection_button.tscn")

@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var buttons_container: VBoxContainer = %ButtonsContainer

func _ready() -> void:
	pass
