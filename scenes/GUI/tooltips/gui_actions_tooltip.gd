class_name GUIActionsTooltip
extends GUITooltip

@onready var _gui_actions_description: GUIActionsDescription = %GUIActionsDescription

func update_with_actions(actions:Array[ActionData]) -> void:
	_gui_actions_description.update_with_actions(actions)
	
