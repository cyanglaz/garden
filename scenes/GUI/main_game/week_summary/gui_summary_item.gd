class_name GUISummaryItem
extends HBoxContainer

@onready var title_label: Label = %TitleLabel
@onready var points_label: Label = %PointsLabel

func update_with_title_and_points(title:String, point:int, point_due_color:Color) -> void:
	title_label.text = title
	points_label.text = str(point)
	points_label.add_theme_color_override("font_color", point_due_color)
