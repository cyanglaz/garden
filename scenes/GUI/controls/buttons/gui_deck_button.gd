class_name GUIDeckButton
extends GUIBasicButton

enum Type {
	ALL,
	DRAW,
	DISCARD
}

@export var type:Type
@onready var _label: Label = %Label
@onready var _background: NinePatchRect = %Background

var _normal_background_color:Color

func _ready() -> void:
	_normal_background_color = _background.self_modulate
	super._ready()

func bind_draw_box(draw_box:DrawBox) -> void:
	var pool := []
	match type:
		Type.ALL:
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			pool = draw_box.pool
			draw_box.pool_updated.connect(_on_pool_updated)
		Type.DRAW:
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			pool = draw_box.draw_pool
			draw_box.draw_pool_updated.connect(_on_pool_updated)
		Type.DISCARD:
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			pool = draw_box.discard_pool
			draw_box.discard_pool_updated.connect(_on_pool_updated)
	_on_pool_updated(pool)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_background:
		return
	match button_state:
		ButtonState.NORMAL, ButtonState.PRESSED, ButtonState.DISABLED, ButtonState.SELECTED:
			_background.self_modulate = _normal_background_color
		ButtonState.HOVERED:
			_background.self_modulate = Constants.COLOR_BEIGE_2

func _on_pool_updated(pool:Array[BingoBallData]) -> void:
	_label.text = str(pool.size())
