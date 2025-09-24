class_name GUIContractTotalResources
extends HBoxContainer

@onready var light_requirement_label: Label = %LightRequirementLabel
@onready var water_requirement_label: Label = %WaterRequirementLabel
@onready var title: Label = %Title

func _ready() -> void:
	title.text = Util.get_localized_string("CONTRACT_TOTAL_RESOURCES_TITLE_TEXT")

func update(light:int, water:int) -> void:
	light_requirement_label.text = str(light)
	water_requirement_label.text = str(water)
