class_name SessionSummary
extends RefCounted

var combat:CombatData
var total_days:int
var total_gold_earned:int

func _init(c:CombatData) -> void:
	self.combat = c