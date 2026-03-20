class_name GUIDeckButton
extends GUIBasicButton

enum Type {
	ALL,
	DRAW,
	DISCARD,
	EXHAUST
}

@export var region_size:Vector2
@export var type:Type
@onready var _label: Label = %Label
@onready var _texture_rect: NinePatchRect = %NinePatchRect

var _size:int = 0
var _label_update_tween:Tween

func _ready() -> void:
	super._ready()

func bind_deck(deck:Deck) -> void:
	var pool := []
	match type:
		Type.ALL:
			pool = deck.pool
			deck.pool_updated.connect(_on_pool_updated)
		Type.DRAW:
			pool = deck.draw_pool
			deck.draw_pool_updated.connect(_on_pool_updated)
		Type.DISCARD:
			pool = deck.discard_pool
			deck.discard_pool_updated.connect(_on_pool_updated)
		Type.EXHAUST:
			pool = deck.exhaust_pool
			deck.exhaust_pool_updated.connect(_on_pool_updated)
	_on_pool_updated(pool)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_texture_rect:
		return
	match button_state:
		ButtonState.NORMAL:
			_texture_rect.region_rect.position = Vector2(0, 0)
		ButtonState.PRESSED:
			_texture_rect.region_rect.position = Vector2(region_size.x, 0)
		ButtonState.HOVERED:
			_texture_rect.region_rect.position = Vector2(region_size.x*2, 0)
		ButtonState.DISABLED:
			_texture_rect.region_rect.position = Vector2(0, region_size.y)
		ButtonState.SELECTED:
			_texture_rect.region_rect.position = Vector2(region_size.x*2, region_size.y)		


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

	_label.text = str(_size)
