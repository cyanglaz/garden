class_name SessionSummary
extends RefCounted

var contract:ContractData
var total_days:int
var total_gold_earned:int

func _init(c:ContractData) -> void:
	self.contract = c