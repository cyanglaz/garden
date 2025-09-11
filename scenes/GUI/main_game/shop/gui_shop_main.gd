class_name GUIShopMain
extends Control


const ADD_CARD_TO_PILE_ANIMATION_TIME := 0.3

signal tool_shop_button_pressed(tool_data:ToolData)
signal next_level_button_pressed()

const ANIMATING_TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const TOOL_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/main_game/shop/shop_buttons/gui_tool_shop_button.tscn")

@onready var tool_container: HBoxContainer = %ToolContainer
@onready var _main_panel: PanelContainer = $MainPanel
@onready var _next_level_button: GUIRichTextButton = %NextLevelButton
@onready var _title: Label = %Title
@onready var _sub_title: Label = %SubTitle

var _weak_tooltip:WeakRef = weakref(null)

var _full_deck_button:GUIDeckButton: get = _get_full_deck_button
var _weak_full_deck_button:WeakRef = weakref(null)

var _display_y := 0.0
var _weak_insufficient_gold_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	_display_y = _main_panel.position.y
	_next_level_button.pressed.connect(_on_next_level_button_pressed)
	_title.text = Util.get_localized_string("SHOP_TITLE")
	_sub_title.text = Util.get_localized_string("SHOP_SUBTITLE")

func setup(full_deck_button:GUIDeckButton) -> void:
	_weak_full_deck_button = weakref(full_deck_button)

func animate_show(number_of_tools:int, gold:int) -> void:
	show()
	_populate_shop(number_of_tools)
	update_for_gold(gold)
	await _play_show_animation()

func update_for_gold(gold:int) -> void:
	for gui_shop_button:GUIShopButton in tool_container.get_children():
		gui_shop_button.update_for_gold(gold)

func _populate_shop(number_of_tools:int) -> void:
	_populate_tools(number_of_tools)

func _populate_tools(number_of_tools) -> void:
	Util.remove_all_children(tool_container)
	var tools := MainDatabase.tool_database.roll_tools(number_of_tools)
	for tool_data:ToolData in tools:
		var tool_shop_button:GUIToolShopButton  = TOOL_SHOP_BUTTON_SCENE.instantiate()
		tool_container.add_child(tool_shop_button)
		tool_shop_button.update_with_tool_data(tool_data)
		tool_shop_button.pressed.connect(_on_tool_shop_button_pressed.bind(tool_shop_button, tool_data))
		tool_shop_button.mouse_exited.connect(_on_shop_button_mouse_exited.bind())
		tool_shop_button.mouse_entered.connect(_on_tool_shop_button_mouse_entered.bind(tool_data, tool_shop_button))

func _play_show_animation() -> void:
	_main_panel.position.y = Constants.PENEL_HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", _display_y, Constants.SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished
	_next_level_button.show()

func animate_hide() -> void:
	_clear_insufficient_gold_tooltip()
	_next_level_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", Constants.PENEL_HIDE_Y, Constants.HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _animate_add_card_to_deck(gui_shop_button:GUIShopButton, tool_data:ToolData) -> void:
	var from_global_position:Vector2 = gui_shop_button.global_position
	var animating_card:GUIToolCardButton = ANIMATING_TOOL_CARD_SCENE.instantiate()
	add_child(animating_card)
	animating_card.update_with_tool_data(tool_data)
	animating_card.global_position = from_global_position
	animating_card.play_move_sound()
	Util.create_scaled_timer(ADD_CARD_TO_PILE_ANIMATION_TIME * 0.25).timeout.connect(func(): animating_card.animation_mode = true)
	var tween := Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.tween_property(animating_card, "global_position", _full_deck_button.global_position, ADD_CARD_TO_PILE_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(animating_card, "size", _full_deck_button.size, ADD_CARD_TO_PILE_ANIMATION_TIME * 0.75).set_delay(ADD_CARD_TO_PILE_ANIMATION_TIME * 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	animating_card.queue_free()

func _clear_insufficient_gold_tooltip() -> void:
	if _weak_insufficient_gold_tooltip.get_ref():
		_weak_insufficient_gold_tooltip.get_ref().queue_free()
		_weak_insufficient_gold_tooltip = weakref(null)

func _get_full_deck_button() -> GUIDeckButton:
	return _weak_full_deck_button.get_ref()

func _on_tool_shop_button_pressed(gui_shop_button:GUIShopButton, tool_data:ToolData) -> void:
	_clear_insufficient_gold_tooltip()
	if gui_shop_button.sufficient_gold:
		tool_shop_button_pressed.emit(tool_data)
		_animate_add_card_to_deck(gui_shop_button, tool_data)
		gui_shop_button.queue_free()
	else:
		_weak_insufficient_gold_tooltip = weakref(Util.display_warning_tooltip(tr("WARNING_INSUFFICIENT_GOLD"), gui_shop_button, false, GUITooltip.TooltipPosition.TOP))

func _on_next_level_button_pressed() -> void:
	await animate_hide()
	next_level_button_pressed.emit()

func _on_shop_button_mouse_exited() -> void:
	_clear_insufficient_gold_tooltip()
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)

func _on_tool_shop_button_mouse_entered(tool_data:ToolData, control:Control) -> void:
	if !tool_data.actions.is_empty():
		_weak_tooltip = weakref(Util.display_tool_card_tooltip(tool_data, control, false, GUITooltip.TooltipPosition.RIGHT, false))
