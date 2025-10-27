class_name ShopMain
extends Node2D

const NUMBER_OF_CARDS := 5

signal finish_button_pressed()
signal tool_shop_button_pressed(tool_data:ToolData, from_global_position:Vector2)

@onready var gui_shop_main: GUIShopMain = %GUIShopMain

func _ready() -> void:
	gui_shop_main.tool_shop_button_pressed.connect(func(tool_data:ToolData, from_global_position:Vector2): tool_shop_button_pressed.emit(tool_data, from_global_position))
	gui_shop_main.finish_button_pressed.connect(func(): finish_button_pressed.emit())

func start(gold:int) -> void:
	await gui_shop_main.animate_show(NUMBER_OF_CARDS, gold)

func update_for_gold(gold:int) -> void:
	gui_shop_main.update_for_gold(gold)
