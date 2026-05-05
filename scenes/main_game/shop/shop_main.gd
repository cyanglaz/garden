class_name ShopMain
extends Node2D

const NUMBER_OF_CARDS := 4

signal finish_button_pressed()
signal shop_button_pressed(cost: int)
signal card_removal_service_used(cost: int)

@onready var gui_shop_main: GUIShopMain = %GUIShopMain

func _ready() -> void:
	gui_shop_main.shop_button_pressed.connect(func(cost): shop_button_pressed.emit(cost))
	gui_shop_main.card_removal_service_used.connect(func(cost): card_removal_service_used.emit(cost))
	gui_shop_main.finish_button_pressed.connect(func(): finish_button_pressed.emit())

func start(gold:int, card_remove_cost:int, card_pool: Array[ToolData], owned_trinkets: Array[TrinketData] = []) -> void:
	var excluded_ids: Array[String] = []
	for t: TrinketData in owned_trinkets:
		excluded_ids.append(t.id)
	gui_shop_main.bind_card_pool(card_pool)
	gui_shop_main.animate_show(NUMBER_OF_CARDS, gold, card_remove_cost, excluded_ids)

func update_for_gold(gold:int) -> void:
	gui_shop_main.update_for_gold(gold)
