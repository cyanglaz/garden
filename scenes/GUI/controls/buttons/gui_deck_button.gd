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
var _size:int = 0
var _label_update_tween:Tween

func _ready() -> void:
	_normal_background_color = _background.self_modulate
	super._ready()

func bind_deck(tool:Deck) -> void:
	var pool := []
	match type:
		Type.ALL:
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			pool = tool.pool
			tool.pool_updated.connect(_on_pool_updated)
		Type.DRAW:
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			pool = tool.draw_pool
			tool.draw_pool_updated.connect(_on_pool_updated)
		Type.DISCARD:
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			pool = tool.discard_pool
			tool.discard_pool_updated.connect(_on_pool_updated)
	_on_pool_updated(pool)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_background:
		return
	match button_state:
		ButtonState.NORMAL, ButtonState.PRESSED, ButtonState.DISABLED, ButtonState.SELECTED:
			_background.self_modulate = _normal_background_color
		ButtonState.HOVERED:
			_background.self_modulate = Constants.COLOR_BEIGE_1

func _on_pool_updated(pool:Array) -> void:
	var old_size := _size
	_size = pool.size()
	if _label_update_tween && _label_update_tween.is_running():
		_label_update_tween.kill()
	_label_update_tween = Util.create_scaled_tween(self)
	_label_update_tween.set_parallel(true)
	var increment := 1 if _size > old_size else -1
	var number_of_increament = abs(old_size - _size)
	if number_of_increament == 0:
		_label_update_tween.kill()
	for i in number_of_increament:
		_label_update_tween.tween_property(_label, "text", str(old_size + increment * (i + 1)), Constants.CARD_ANIMATION_DELAY).set_delay(Constants.CARD_ANIMATION_DELAY * i)

	# _label.text = str(_size)
