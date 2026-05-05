class_name GUIShopMain
extends CanvasLayer

const ADD_CARD_TO_PILE_ANIMATION_TIME := 0.3

signal shop_button_pressed(cost: int)
signal finish_button_pressed()

const TOOL_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/shop/shop_buttons/gui_tool_shop_button.tscn")
const TRINKET_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/shop/shop_buttons/gui_trinket_shop_button.tscn")
const ENCHANT_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/shop/shop_buttons/gui_enchant_shop_button.tscn")

@onready var tool_container: HBoxContainer = %ToolContainer
@onready var trinket_container: HBoxContainer = %TrinketContainer
@onready var enchant_container: HBoxContainer = %EnchantContainer
@onready var finish_button: GUIRichTextButton = %FinishButton
@onready var gui_enchant_main: GUIEnchantMain = %GUIEnchantMain
#@onready var _main_panel: PanelContainer = %MainPanel
@onready var _insufficient_gold_audio: AudioStreamPlayer2D = %InsufficientGoldAudio

# Shared reference to MainGame.card_pool (GDScript Arrays are reference-shared,
# so appends/removals from MainGame propagate here automatically).
var _card_pool_ref: Array[ToolData] = []
# Pending enchant purchase state (valid between opening GUIEnchantMain and resolving it).
var _pending_enchant_button: GUIEnchantShopButton = null
var _pending_enchant_cost: int = 0

func _ready() -> void:
	#_display_y = _main_panel.position.y
	finish_button.pressed.connect(_on_finish_button_pressed)
	gui_enchant_main.hide()
	gui_enchant_main.enchant_finished.connect(_on_enchant_finished)
	gui_enchant_main.enchant_card_pressed.connect(_on_enchant_card_pressed)
	gui_enchant_main.enchant_cancelled.connect(_on_enchant_cancelled)

func bind_card_pool(card_pool: Array[ToolData]) -> void:
	_card_pool_ref = card_pool

func animate_show(number_of_tools:int, gold:int, excluded_trinket_ids: Array[String] = []) -> void:
	show()
	_populate_shop(number_of_tools, excluded_trinket_ids)
	update_for_gold(gold)
	_play_show_animation()

func animate_hide() -> void:
	Events.request_hide_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
	finish_button.hide()
	#var tween := Util.create_scaled_tween(self)
	#tween.tween_property(_main_panel, "position:y", Constants.PENEL_HIDE_Y, Constants.HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	#await tween.finished
	hide()

func update_for_gold(gold:int) -> void:
	for gui_shop_button: GUIShopButton in tool_container.get_children():
		gui_shop_button.update_for_gold(gold)
	for gui_shop_button: GUIShopButton in trinket_container.get_children():
		gui_shop_button.update_for_gold(gold)
	for gui_shop_button: GUIShopButton in enchant_container.get_children():
		gui_shop_button.update_for_gold(gold)

func _populate_shop(number_of_tools:int, excluded_trinket_ids: Array[String] = []) -> void:
	_populate_tools(number_of_tools)
	_populate_trinkets(excluded_trinket_ids)
	_populate_enchants()

func _populate_tools(number_of_tools) -> void:
	Util.remove_all_children(tool_container)
	var tools := MainDatabase.tool_database.roll_tools(number_of_tools, -1)
	for tool_data:ToolData in tools:
		var tool_shop_button:GUIToolShopButton = TOOL_SHOP_BUTTON_SCENE.instantiate()
		tool_container.add_child(tool_shop_button)
		tool_shop_button.update_with_tool_data(tool_data)
		tool_shop_button.pressed.connect(_on_tool_shop_button_pressed.bind(tool_shop_button, tool_data))
		tool_shop_button.mouse_exited.connect(_on_shop_button_mouse_exited.bind())

func _populate_trinkets(excluded_trinket_ids: Array[String] = []) -> void:
	Util.remove_all_children(trinket_container)
	var trinkets := MainDatabase.trinket_database.roll_shop_trinkets(excluded_trinket_ids)
	for trinket_data: TrinketData in trinkets:
		var trinket_shop_button: GUITrinketShopButton = TRINKET_SHOP_BUTTON_SCENE.instantiate()
		trinket_container.add_child(trinket_shop_button)
		trinket_shop_button.update_with_trinket_data(trinket_data)
		trinket_shop_button.pressed.connect(_on_trinket_shop_button_pressed.bind(trinket_shop_button, trinket_data))
		trinket_shop_button.mouse_exited.connect(_on_shop_button_mouse_exited.bind())

func _populate_enchants() -> void:
	Util.remove_all_children(enchant_container)
	var enchants: Array[EnchantData] = MainDatabase.enchant_database.roll_shop_enchants()
	for enchant_data: EnchantData in enchants:
		var enchant_shop_button: GUIEnchantShopButton = ENCHANT_SHOP_BUTTON_SCENE.instantiate()
		enchant_container.add_child(enchant_shop_button)
		enchant_shop_button.update_with_enchant_data(enchant_data)
		enchant_shop_button.pressed.connect(_on_enchant_shop_button_pressed.bind(enchant_shop_button, enchant_data))
		enchant_shop_button.mouse_exited.connect(_on_shop_button_mouse_exited.bind())

func _play_show_animation() -> void:
	#_main_panel.position.y = Constants.PENEL_HIDE_Y
	#var tween := Util.create_scaled_tween(self)
	#tween.tween_property(_main_panel, "position:y", _display_y, Constants.SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	#await tween.finished
	finish_button.show()

func _on_tool_shop_button_pressed(gui_shop_button:GUIShopButton, tool_data:ToolData) -> void:
	Events.request_hide_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
	if gui_shop_button.sufficient_gold:
		Events.request_add_card_to_deck.emit(tool_data, gui_shop_button.global_position)
		shop_button_pressed.emit(tool_data.cost)
		gui_shop_button.sold_out = true
	else:
		Util.play_error_shake_animation(gui_shop_button, "position", gui_shop_button.position)
		Events.request_show_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
		_insufficient_gold_audio.play()

func _on_trinket_shop_button_pressed(gui_shop_button: GUIShopButton, trinket_data: TrinketData) -> void:
	Events.request_hide_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
	if gui_shop_button.sufficient_gold:
		Events.request_add_trinket_to_collection.emit(trinket_data, gui_shop_button.global_position, 1.0)
		shop_button_pressed.emit(trinket_data.cost)
		gui_shop_button.sold_out = true
	else:
		Util.play_error_shake_animation(gui_shop_button, "position", gui_shop_button.position)
		Events.request_show_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
		_insufficient_gold_audio.play()

func _on_enchant_shop_button_pressed(gui_shop_button: GUIEnchantShopButton, enchant_data: EnchantData) -> void:
	Events.request_hide_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
	if !gui_shop_button.sufficient_gold:
		Util.play_error_shake_animation(gui_shop_button, "position", gui_shop_button.position)
		Events.request_show_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
		_insufficient_gold_audio.play()
		return
	_pending_enchant_button = gui_shop_button
	_pending_enchant_cost = enchant_data.cost
	gui_enchant_main.setup_with_card_pool(_card_pool_ref, enchant_data)
	gui_enchant_main.show()

func _on_enchant_finished(old_tool_data: ToolData) -> void:
	Events.request_remove_card_from_deck.emit(old_tool_data)

func _on_enchant_card_pressed(tool_data: ToolData, enchant_card_global_position: Vector2) -> void:
	Events.request_add_card_to_deck.emit(tool_data, enchant_card_global_position)
	shop_button_pressed.emit(_pending_enchant_cost)
	if _pending_enchant_button:
		_pending_enchant_button.sold_out = true
	_pending_enchant_button = null
	_pending_enchant_cost = 0

func _on_enchant_cancelled() -> void:
	_pending_enchant_button = null
	_pending_enchant_cost = 0

func _on_finish_button_pressed() -> void:
	animate_hide()
	finish_button_pressed.emit()

func _on_shop_button_mouse_exited() -> void:
	Events.request_hide_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
