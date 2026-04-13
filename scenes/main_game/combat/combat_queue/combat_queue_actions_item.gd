class_name CombatQueueActionsItem
extends CombatQueueItem

## [ActionData] list for [ActionsApplier.apply_actions]. [member tool_card] may be null for non-card flows
## if no action needs it (see [ActionsApplier] random secondary selection).
var actions: Array = []
var tool_card: GUIToolCardButton

func _init(p_actions: Array = [], p_tool_card: GUIToolCardButton = null) -> void:
	actions = p_actions.duplicate()
	tool_card = p_tool_card
