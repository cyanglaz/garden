class_name GUIIconButton
extends GUIBasicButton

@export var button_icon:Texture : set = _set_button_icon
@export var show_shortcut_icon:bool = true

@onready var _texture_rect: TextureRect = %TextureRect

@onready var _border: NinePatchRect = %Border
@onready var _shortcut_icon: TextureRect = %ShortcutIcon
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

var _short_cut_image_region:Rect2i

func _ready() -> void:
	super._ready()
	_set_button_icon(button_icon)
	_set_short_cut(short_cut)

func _set_button_icon(val:Texture):
	button_icon = val
	if _texture_rect:
		_texture_rect.texture = button_icon

func _set_short_cut(val:String) -> void:
	super._set_short_cut(val)
	if !_shortcut_icon:
		return
	short_cut = val
	if !short_cut.is_empty() && show_shortcut_icon:
		if Constants.SHORT_CUT_ICONS.has(short_cut):
			_shortcut_icon.show()
		_short_cut_image_region = Rect2i(Constants.SHORT_CUT_ICONS[short_cut] * SHORT_CUT_ICON_SIZE, Vector2i(SHORT_CUT_ICON_SIZE, SHORT_CUT_ICON_SIZE))
		(_shortcut_icon.texture as AtlasTexture).region = _short_cut_image_region
	else:
		_shortcut_icon.hide()

func _set_button_state(val:ButtonState) -> void:
	if button_state == ButtonState.PRESSED && _texture_rect:
		_texture_rect.position.y -= 1
	super._set_button_state(val)
	if !_border:
		return
	match button_state:
		ButtonState.NORMAL:
			_border.region_rect.position = Vector2(0, 0)
		ButtonState.PRESSED:
			_border.region_rect.position = Vector2(16, 0)
			_texture_rect.position.y += 1
		ButtonState.HOVERED:
			_border.region_rect.position = Vector2(32, 0)
		ButtonState.DISABLED:
			_border.region_rect.position = Vector2(0, 16)
		ButtonState.SELECTED:
			_border.region_rect.position = Vector2(16, 16)				
