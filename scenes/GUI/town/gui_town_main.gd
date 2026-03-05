class_name GUITownMain
extends CanvasLayer

signal bind_finished(tool_data:ToolData, front_card_data:ToolData, back_card_data:ToolData)
signal bind_card_pressed(tool_data:ToolData, bind_card_global_position:Vector2)

@onready var gui_bind_main: GUIBindMain = %GUIBindMain

func _ready() -> void:
	gui_bind_main.bind_finished.connect(_on_bind_finished)
	gui_bind_main.bind_card_pressed.connect(_on_bind_card_pressed)

func setup_with_card_pool(card_pool:Array[ToolData]) -> void:
	gui_bind_main.setup_with_card_pool(card_pool)

func show_bind_main() -> void:
	gui_bind_main.show()

func _on_bind_finished(tool_data:ToolData, front_card_data:ToolData, back_card_data:ToolData) -> void:
	bind_finished.emit(tool_data, front_card_data, back_card_data)

func _on_bind_card_pressed(tool_data:ToolData, bind_card_global_position:Vector2) -> void:
	bind_card_pressed.emit(tool_data, bind_card_global_position)
