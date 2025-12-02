class_name GUICombatTooltip
extends GUITooltip

@onready var gui_combat: GUICombat = %GUICombat

func _update_with_tooltip_request() -> void:
	var combat_data:CombatData = _tooltip_request.data as CombatData
	gui_combat.update_with_combat_data(combat_data)
