class_name GUIContractTotalResources
extends VBoxContainer

@onready var title: Label = %Title
@onready var _total_light: Label = %TotalLight
@onready var _total_water: Label = %TotalWater

func _ready() -> void:
	title.text = Util.get_localized_string("CONTRACT_TOTAL_RESOURCES_TITLE_TEXT")
	_total_light.add_theme_color_override("font_color", Constants.LIGHT_THEME_COLOR)
	_total_water.add_theme_color_override("font_color", Constants.WATER_THEME_COLOR)

func update(light:int, water:int) -> void:
	_total_light.text = str(light)
	_total_water.text = str(water)
