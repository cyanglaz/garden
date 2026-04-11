class_name GUIRemoveCardMain
extends CanvasLayer

signal remove_card_finished()

@onready var gui_tool_cards_viewer: GUIToolCardsViewer = %GUIToolCardsViewer

func _ready() -> void:
	gui_tool_cards_viewer.card_selected.connect(_on_card_selected)
	
func show_with_pool(pool:Array, title:String) -> void:
	gui_tool_cards_viewer.animated_show_with_pool(pool, title, null)

func _on_card_selected(gui_tool_card_button:GUIToolCardButton) -> void:
	Events.request_remove_card_from_deck.emit(gui_tool_card_button.tool_data)
	remove_card_finished.emit()
