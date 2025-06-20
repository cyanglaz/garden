class_name GUIShopContainer
extends GUIPopupContainer

signal item_purchased(data:Variant, cost:int)
signal finished()

const GUI_SHOP_CARD_SCENE := preload("res://scenes/GUI/controls/shop_card/gui_shop_card.tscn")
const PADDING := 4

@onready var _blueprint_container: HBoxContainer = %BlueprintContainer
@onready var _item_container: HBoxContainer = %ItemContainer
@onready var _leave_button: GUIRichTextButton = %LeaveButton
@onready var _gui_character_tooltip: GUICharacterTooltip = %GUICharacterTooltip
@onready var _gui_item_tooltip: GUIItemTooltip = %GUIItemTooltip

var _blueprint_datas := []
var _item_datas := []
var _selected_index:int = -1

func _ready() -> void:
	_leave_button.action_evoked.connect(_on_leave_button_clicked)
	_gui_character_tooltip.hide()
	_gui_item_tooltip.hide()
	
func animate_show() -> void:
	super.animate_show()
	_animate_layout_cards()

func setup(blueprint_datas:Array, item_datas:Array) -> void:
	_selected_index = -1
	_item_datas = item_datas.duplicate()
	_blueprint_datas = blueprint_datas.duplicate()
	Util.remove_all_children(_item_container)
	Util.remove_all_children(_blueprint_container)
	var index := 0
	for item_data:ItemData in _item_datas:
		var item_card:GUIShopCard = GUI_SHOP_CARD_SCENE.instantiate()
		_item_container.add_child(item_card)
		item_card.setup(item_data)
		item_card.purchased_button_clicked.connect(_on_purchase_button_clicked.bind(index, _item_datas))
		item_card.mouse_hovered.connect(_on_mouse_hovered.bind(item_data))
		index += 1
	index = 0
	for blueprint_data:SummonData in blueprint_datas:
		var blueprint_card:GUIShopCard = GUI_SHOP_CARD_SCENE.instantiate()
		_blueprint_container.add_child(blueprint_card)
		blueprint_card.setup(blueprint_data)
		blueprint_card.purchased_button_clicked.connect(_on_purchase_button_clicked.bind(index, _blueprint_datas))
		blueprint_card.mouse_hovered.connect(_on_mouse_hovered.bind(blueprint_data))
		index += 1
	_disable_cards()

func _animate_layout_cards(_starting_index:int = 0) -> void:
	_enable_cards()

func _disable_cards() -> void:
	for child:GUIShopCard in _item_container.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child:GUIShopCard in _blueprint_container.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _enable_cards() -> void:
	for child:GUIShopCard in _item_container.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_STOP
	for child:GUIShopCard in _blueprint_container.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_STOP

#region events

func _on_purchase_button_clicked(index:int, datas:Array) -> void:
	var data:Variant = datas[index]
	assert("cost" in data)
	item_purchased.emit(data, data.cost)

func _on_leave_button_clicked() -> void:
	await animate_hide()
	finished.emit()

func _on_mouse_hovered(on:bool, data:Variant) -> void:
	if on:
		if data is ItemData:
			_gui_character_tooltip.hide()
			_gui_item_tooltip.setup_with_item(data)
			_gui_item_tooltip.show()
		elif data is SummonData:
			_gui_item_tooltip.hide()
			_gui_character_tooltip.setup_with_character(data.character_data)
			_gui_character_tooltip.show()
	else:
		_gui_item_tooltip.hide()
		_gui_character_tooltip.hide()

#endregion
