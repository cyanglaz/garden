class_name GUIShopPanel
extends PanelContainer

signal shop_button_pressed()

@onready var gui_shop_button: GUIShopButton = %GUIShopButton

var cost:int:set = _set_cost
var highlighted := false: set = _set_highlighted

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_shop_button.pressed.connect(_on_shop_button_pressed)

func update_for_gold(gold:int) -> void:
	gui_shop_button.sufficient_gold = cost <= gold

func _set_cost(val:int) -> void:
	cost = val
	gui_shop_button.update_with_cost(cost)

func _on_mouse_entered() -> void:
	highlighted = true

func _on_mouse_exited() -> void:
	highlighted = false

func _on_shop_button_pressed() -> void:
	shop_button_pressed.emit()

func _set_highlighted(val:bool) -> void:
	highlighted = val
