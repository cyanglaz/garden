class_name GUITownMain
extends CanvasLayer

signal enchant_finished(old_tool_data:ToolData)
signal enchant_card_pressed(tool_data:ToolData, enchant_card_global_position:Vector2)

@onready var gui_enchant_main: GUIEnchantMain = %GUIEnchantMain

func _ready() -> void:
	gui_enchant_main.enchant_finished.connect(_on_enchant_finished)
	gui_enchant_main.enchant_card_pressed.connect(_on_enchant_card_pressed)

func setup_with_card_pool(card_pool:Array[ToolData], enchant_data:EnchantData) -> void:
	gui_enchant_main.setup_with_card_pool(card_pool, enchant_data)

func show_enchant_main() -> void:
	gui_enchant_main.show()

func _on_enchant_finished(tool_data:ToolData, front_card_data:ToolData, back_card_data:ToolData) -> void:
	enchant_finished.emit(tool_data, front_card_data, back_card_data)

func _on_enchant_card_pressed(tool_data:ToolData, enchant_card_global_position:Vector2) -> void:
	enchant_card_pressed.emit(tool_data, enchant_card_global_position)
