class_name GUICombatConclusion
extends PanelContainer

@onready var mob_summoned: Label = %MobSummoned
@onready var mob_killed: Label = %MobKilled
@onready var turns_taken: Label = %TurnsTaken

func setup_with_combat_conclusion(combat_conslusion:CombatConclusion) -> void:
	mob_summoned.text = str(combat_conslusion.mob_summoned)
	mob_killed.text = str(combat_conslusion.mob_killed)
	turns_taken.text = str(combat_conslusion.turn_taken)
