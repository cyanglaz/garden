class_name ShopMain
extends Node2D

const NUMBER_OF_CARDS := 5

signal finish_button_pressed()
signal shop_button_pressed(cost: int)

@onready var gui_shop_main: GUIShopMain = %GUIShopMain

func _ready() -> void:
	gui_shop_main.shop_button_pressed.connect(func(cost): shop_button_pressed.emit(cost))
	gui_shop_main.finish_button_pressed.connect(func(): finish_button_pressed.emit())

func start(gold:int, owned_trinkets: Array[TrinketData] = []) -> void:
	var excluded_ids: Array[String] = owned_trinkets.map(func(t: TrinketData) -> String: return t.id)
	await gui_shop_main.animate_show(NUMBER_OF_CARDS, gold, excluded_ids)

func update_for_gold(gold:int) -> void:
	gui_shop_main.update_for_gold(gold)
