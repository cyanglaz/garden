class_name GUIDemoEndContainer
extends GUIPopupContainer


@onready var ok_button: GUIRichTextButton = %OKButton
@onready var _title_label: Label = %Label
@onready var _subtitle_label: Label = %Label2

func _ready() -> void:
	_title_label.text = Util.get_localized_string("DEMO_END_TITLE")
	_subtitle_label.text = Util.get_localized_string("DEMO_END_SUBTITLE")
	ok_button.pressed.connect(_on_ok_button_pressed)

func _on_ok_button_pressed() -> void:
	Main.weak_main().get_ref().show_menu()
