class_name GUIButtonTooltip
extends GUITooltip

@onready var _description: RichTextLabel = %Description
@onready var _shortcut_label: RichTextLabel = %ShortcutLabel

func setup(description:String, shortcut:String) -> void:
	_description.text = description
	if shortcut.is_empty():
		_shortcut_label.hide()
		return
	var action_events := InputMap.action_get_events(shortcut)
	var shortcut_string = action_events.front().as_text()
	if shortcut_string.contains("(Physical)"):
		shortcut_string = shortcut_string.replace("(Physical)", "")
	_shortcut_label.text = str("ShortCut: ", shortcut_string)
