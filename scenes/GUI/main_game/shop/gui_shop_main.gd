class_name GUIShopMain
extends CanvasLayer

const ADD_CARD_TO_PILE_ANIMATION_TIME := 0.3

signal tool_shop_button_pressed(tool_data:ToolData, from_global_position:Vector2)
signal finish_button_pressed()

const ANIMATING_TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const TOOL_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/main_game/shop/shop_buttons/gui_tool_shop_button.tscn")

@onready var tool_container: HBoxContainer = %ToolContainer
@onready var finish_button: GUIRichTextButton = %FinishButton
@onready var _main_panel: PanelContainer = %MainPanel
@onready var _title: Label = %Title
@onready var _sub_title: Label = %SubTitle

var _tooltip_id:String = ""

var _display_y := 0.0

func _ready() -> void:
	_display_y = _main_panel.position.y
	finish_button.pressed.connect(_on_finish_button_pressed)
	_title.text = Util.get_localized_string("SHOP_TITLE")
	_sub_title.text = Util.get_localized_string("SHOP_SUBTITLE")
	animate_show(0, 50)

func animate_show(number_of_tools:int, gold:int) -> void:
	show()
	_populate_shop(number_of_tools)
	update_for_gold(gold)
	await _play_show_animation()

func animate_hide() -> void:
	Events.request_hide_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
	finish_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", Constants.PENEL_HIDE_Y, Constants.HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func update_for_gold(gold:int) -> void:
	for gui_shop_button:GUIShopButton in tool_container.get_children():
		gui_shop_button.update_for_gold(gold)

func _populate_shop(number_of_tools:int) -> void:
	_populate_tools(number_of_tools)

func _populate_tools(number_of_tools) -> void:
	Util.remove_all_children(tool_container)
	var tools := MainDatabase.tool_database.roll_tools(number_of_tools, -1)
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
	finish_button.show()

func _on_tool_shop_button_pressed(gui_shop_button:GUIShopButton, tool_data:ToolData) -> void:
	Events.request_hide_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
	if gui_shop_button.sufficient_gold:
		tool_shop_button_pressed.emit(tool_data, gui_shop_button.global_position)
		gui_shop_button.queue_free()
	else:
		Events.request_show_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)

func _on_finish_button_pressed() -> void:
	await animate_hide()
	finish_button_pressed.emit()

func _on_shop_button_mouse_exited() -> void:
	Events.request_hide_warning.emit(WarningManager.WarningType.INSUFFICIENT_GOLD)
	Events.request_hide_tooltip.emit(_tooltip_id)

func _on_tool_shop_button_mouse_entered(tool_data:ToolData, control:Control) -> void:
	if !tool_data.actions.is_empty():
		_tooltip_id = Util.get_uuid()
		Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.TOOL_CARD, tool_data, _tooltip_id, control, false, GUITooltip.TooltipPosition.RIGHT, false)
