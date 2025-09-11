class_name GUIPopupAlert
extends GUIPopupContainer

signal close_button_clicked()
signal by_pass_button_clicked()

@onready var title: Label = %Title
@onready var message: Label = %Message

@onready var close_button: GUIRichTextButton = %CloseButton
@onready var by_pass_button: GUIRichTextButton = %ByPassButton

func _ready() -> void:
	close_button.pressed.connect(_on_button_evoked.bind(close_button))
	by_pass_button.pressed.connect(_on_button_evoked.bind(by_pass_button))

func setup(title_string:String, message_string:String, close_button_title:String, by_pass_button_title:String) -> void:
	title.text = tr(title_string)
	message.text = tr(message_string)
	assert(!close_button_title.is_empty() || !by_pass_button_title.is_empty())
	if !close_button_title.is_empty():
		close_button.show()
		close_button.rich_text = tr(close_button_title)
	if !by_pass_button_title.is_empty():
		by_pass_button.show()
		by_pass_button.rich_text = tr(by_pass_button_title)

func animate_hide() -> void:
	await super.animate_hide()
	queue_free()

func _on_button_evoked(button:GUIRichTextButton) -> void:
	animate_hide()
	if button == close_button:
		close_button_clicked.emit()
	else:
		by_pass_button_clicked.emit()
