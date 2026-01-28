class_name AttackData
extends ThingData

enum AttackType {
	SIMPLE,
}
@export var attack_type:AttackType
@export var damage:int
@export var target_positions:Array[int]

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_attack: AttackData = other as AttackData
	attack_type = other_attack.attack_type
	damage = other_attack.damage
	target_positions = other_attack.target_positions.duplicate()

func get_duplicate() -> AttackData:
	var dup:AttackData = AttackData.new()
	dup.copy(self)
	return dup
