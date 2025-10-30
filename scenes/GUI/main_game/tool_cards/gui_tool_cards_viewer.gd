class_name GUIToolCardsViewer
extends Control

const TOOL_CARD_BUTTON_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")

@onready var _grid_container: GridContainer = %GridContainer
@onready var _back_button: GUIRichTextButton = %BackButton
@onready var _main_container: VBoxContainer = %MainContainer
@onready var _title: Label = %Title

var _display_y := 0.0

func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_evoked)
	_display_y = _main_container.position.y
	_back_button.hide()

func animated_show_with_pool(pool:Array, title:String) -> void:
	PauseManager.try_pause()
	_title.text = title
	show()
	Util.remove_all_children(_grid_container)
	#var card_size := Vector2.ONE
	for tool_data in pool:
		var gui_tool_card: GUIToolCardButton = TOOL_CARD_BUTTON_SCENE.instantiate()
		_grid_container.add_child(gui_tool_card)
		gui_tool_card.mouse_disabled = false
		gui_tool_card.update_with_tool_data(tool_data)
		gui_tool_card.mouse_entered.connect(_on_mouse_entered.bind(gui_tool_card))
		gui_tool_card.mouse_exited.connect(_on_mouse_exited)
		#card_size = GUIToolCardButton.SIZE
	@warning_ignore("integer_division")
	#var rows := pool.size()/_grid_container.columns
	#var v_seperation:int = _grid_container.get_theme_constant("v_separation")
	#var content_height:float = rows * (card_size.y + v_seperation) - v_seperation
	#if content_height > MAX_SCROLL_SIZE_Y:
		#_scroll_container.custom_minimum_size.y = MAX_SCROLL_SIZE_Y
		#_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	#else:
		#_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		#_scroll_container.custom_minimum_size.y = 0
	_play_show_animation()

func _play_show_animation() -> void:
	_main_container.position.y = Constants.PENEL_HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_container, "position:y", _display_y, Constants.SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished
	_back_button.show()

func animate_hide() -> void:
	_back_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_container, "position:y", Constants.PENEL_HIDE_Y, Constants.HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _on_back_button_evoked() -> void:
	animate_hide()
	PauseManager.try_unpause()

func _on_mouse_entered(gui_tool_card:GUIToolCardButton) -> void:
	for tool_card:GUIToolCardButton in _grid_container.get_children():
		if tool_card == gui_tool_card:
			tool_card.card_state = GUIToolCardButton.CardState.HIGHLIGHTED
			continue
		tool_card.card_state = GUIToolCardButton.CardState.NORMAL
	Events.update_hovered_data.emit(gui_tool_card.tool_data)
	
func _on_mouse_exited() -> void:
	for tool_card:GUIToolCardButton in _grid_container.get_children():
		tool_card.card_state = GUIToolCardButton.CardState.NORMAL
