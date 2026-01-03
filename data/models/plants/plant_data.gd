class_name PlantData
extends ThingData

@export var light:int
@export var water:int
@export var difficulty:int
@export var chapters:Array[int]
@export var abilities:Dictionary
@export var initial_field_status:Dictionary
@export var attacks:Array[AttackData]

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_plant: PlantData = other as PlantData
	light = other_plant.light
	water = other_plant.water
	difficulty = other_plant.difficulty
	chapters = other_plant.chapters.duplicate()
	abilities = other_plant.abilities.duplicate()
	initial_field_status = other_plant.initial_field_status.duplicate()
	attacks = other_plant.attacks.duplicate()

func get_duplicate() -> PlantData:
	var dup:PlantData = PlantData.new()
	dup.copy(self)
	return dup
