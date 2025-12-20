class_name GUIForgeMain
extends Control

@onready var title_label: Label = %TitleLabel
@onready var front_card_placeholder: GUICardPlaceHolder = %FrontCardPlaceholder
@onready var back_card_placeholder: GUICardPlaceHolder = %BackCardPlaceholder
@onready var front_card_label: Label = %FrontCardLabel
@onready var back_card_label: Label = %BackCardLabel
@onready var cancel_button: GUIRichTextButton = %CancelButton
@onready var forge_button: GUIRichTextButton = %ForgeButton
@onready var gui_tool_cards_viewer: GUIToolCardsViewer = %GUIToolCardsViewer

var _card_pool:Array = []
var _selecting_front_card:bool = false

func _ready() -> void:
	forge_button.button_state = GUIBasicButton.ButtonState.DISABLED
	title_label.text = Util.get_localized_string("FORGE_TITLE")
	front_card_label.text = Util.get_localized_string("FORGE_FRONT_CARD_LABEL")
	back_card_label.text = Util.get_localized_string("FORGE_BACK_CARD_LABEL")
	front_card_placeholder.button_enabled = true
	back_card_placeholder.button_enabled = true
	front_card_placeholder.button_pressed.connect(_on_front_card_placeholder_button_pressed)
	back_card_placeholder.button_pressed.connect(_on_back_card_placeholder_button_pressed)
	gui_tool_cards_viewer.hide()
	gui_tool_cards_viewer.card_selected.connect(_on_card_selected)

func setup_with_card_pool(card_pool:Array) -> void:
	_card_pool = card_pool

func _on_front_card_placeholder_button_pressed() -> void:
	gui_tool_cards_viewer.animated_show_with_pool(_card_pool, Util.get_localized_string("FORGE_FRONT_CARD_TITLE"))
	_selecting_front_card = true

func _on_back_card_placeholder_button_pressed() -> void:
	gui_tool_cards_viewer.animated_show_with_pool(_card_pool, Util.get_localized_string("FORGE_BACK_CARD_TITLE"))
	_selecting_front_card = false

func _on_card_selected(gui_tool_card:GUIToolCardButton) -> void:
	if _selecting_front_card:
		pass
	else:
		pass
