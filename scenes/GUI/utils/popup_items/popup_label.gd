class_name PopupLabel
extends PopupThing

@onready var label: Label = %Label

func _ready() -> void:
	top_level = true

func animate_show_label(value:String, height:float, spread:float, time:float, color:Color):
	label.text = value
	label.add_theme_color_override("font_color", color)
	await animate_show(height, spread, time)

func animate_show_label_and_destroy(value:String, height:float, spread:float, show_time:float, destroy_time:float, color:Color) -> void:
	await animate_show_label(value, height, spread, show_time, color)
	animate_destroy(destroy_time)
