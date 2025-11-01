class_name BossData
extends ThingData

@export var primary_plant_id:String

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_boss: BossData = other as BossData
	primary_plant_id = other_boss.primary_plant_id

func get_duplicate() -> BossData:
	var dup:BossData = BossData.new()
	dup.copy(self)
	return dup
