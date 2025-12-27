class_name GUITownMain
extends CanvasLayer

signal forge_finished(tool_data:ToolData, front_card_data:ToolData, back_card_data:ToolData, forged_card_global_position:Vector2)

@onready var gui_forge_main: GUIForgeMain = %GUIForgeMain

func _ready() -> void:
	gui_forge_main.forge_finished.connect(_on_forge_finished)

func setup_with_card_pool(card_pool:Array[ToolData]) -> void:
	gui_forge_main.setup_with_card_pool(card_pool)

func show_forge_main() -> void:
	gui_forge_main.show()

func _on_forge_finished(tool_data:ToolData, front_card_data:ToolData, back_card_data:ToolData, forged_card_global_position:Vector2) -> void:
	forge_finished.emit(tool_data, front_card_data, back_card_data, forged_card_global_position)
