class_name GUIActionsTooltip
extends GUITooltip

@onready var _title_label: Label = %TitleLabel
@onready var _gui_actions_description: GUIActionsDescription = %GUIActionsDescription

func _update_with_tooltip_request() -> void:
	var title: String = _tooltip_request.additional_data.get("title", "")
	_title_label.visible = !title.is_empty()
	_title_label.text = title
	_gui_actions_description.update_with_actions(_tooltip_request.data as Array, null)

func get_action_description(index:int) -> String:
	var one_action_description:GUIOneActionDescription = _gui_actions_description.get_child(index)
	return one_action_description.rich_text_label.text
