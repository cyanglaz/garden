class_name GUITownMain
extends CanvasLayer

@onready var gui_forge_main: GUIForgeMain = %GUIForgeMain

func setup_with_card_pool(card_pool:Array[ToolData]) -> void:
	gui_forge_main.setup_with_card_pool(card_pool)

func show_forge_main() -> void:
	gui_forge_main.show()
