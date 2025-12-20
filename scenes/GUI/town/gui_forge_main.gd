class_name GUIForgeMain
extends Control

@onready var title_label: Label = %TitleLabel
@onready var front_card_placeholder: PanelContainer = %FrontCardPlaceholder
@onready var back_card_placeholder: PanelContainer = %BackCardPlaceholder
@onready var front_card_label: Label = %FrontCardLabel
@onready var back_card_label: Label = %BackCardLabel
@onready var cancel_button: GUIRichTextButton = %CancelButton
@onready var forge_button: GUIRichTextButton = %ForgeButton


func _ready() -> void:
	forge_button.button_state = GUIBasicButton.ButtonState.DISABLED
	title_label.text = Util.get_localized_string("FORGE_TITLE")
	front_card_label.text = Util.get_localized_string("FORGE_FRONT_CARD_LABEL")
	back_card_label.text = Util.get_localized_string("FORGE_BACK_CARD_LABEL")
