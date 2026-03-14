class_name GUICreditsPanel
extends GUIPopupContainer

@onready var _back_button: GUIRichTextButton = %BackButton
@onready var _credits_title: Label = %TitleLabel
@onready var _created_by_title: Label = %CreatedByTitle
@onready var _music_title: Label = %MusicTitle

func _ready() -> void:
	_credits_title.text = Util.get_localized_string("CREDITS") + "\n"
	_created_by_title.text = Util.get_localized_string("CREDITS_CREATED_BY")
	_music_title.text = Util.get_localized_string("CREDITS_MUSIC") + "\n"
	_back_button.pressed.connect(_on_back_button_up)

func _on_back_button_up() -> void:
	animate_hide()
