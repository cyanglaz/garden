class_name PopupLabel
extends PopupThing

@onready var _label: Label = %Label

func _ready() -> void:
	top_level = true

func animate_show_label(value:String, height:float, spread:float, time:float, color:Color):
	_label.text = value
	_label.self_modulate = color
	animate_show(height, spread, time)

func animate_destroy(time:float) -> void:
	var tween = Util.create_scaled_tween(self)
	tween.tween_property(self, "modulate:a", 0.0, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	await tween.finished
	queue_free()

func animate_show_label_and_destroy(value:String, height:float, spread:float, show_time:float, destroy_time:float, color:Color) -> void:
	await animate_show_label(value, height, spread, show_time, color)
	animate_destroy(destroy_time)
