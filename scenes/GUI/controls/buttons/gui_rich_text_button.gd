class_name GUIRichTextButton
extends GUIBasicButton

@export var localization_text_key:String: set = _set_localization_text_key

@onready var _rich_text_label: RichTextLabel = %RichTextLabel

@onready var _border: NinePatchRect = %Border
@onready var _shortcut_icon: TextureRect = %ShortcutIcon
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

var _short_cut_image_region:Rect2i

var rich_text:String: set = _set_rich_text
var _normal_original_label_position:Vector2

func _ready() -> void:
	super._ready()
	_set_localization_text_key(localization_text_key)
	_normal_original_label_position = _rich_text_label.position
			
func _set_rich_text(val:String):
	rich_text = val
	if _rich_text_label:
		_rich_text_label.clear()
		var bbc = val
		_rich_text_label.text = bbc
		_set_text_color(button_state)
	
func _set_short_cut(val:String) -> void:
	super._set_short_cut(val)
	if !_shortcut_icon:
		return
	if !short_cut.is_empty():
		if Constants.SHORT_CUT_ICONS.has(short_cut):
			_shortcut_icon.show()
			_short_cut_image_region = Rect2i(Constants.SHORT_CUT_ICONS[short_cut] * SHORT_CUT_ICON_SIZE, Vector2i(SHORT_CUT_ICON_SIZE, SHORT_CUT_ICON_SIZE))
			(_shortcut_icon.texture as AtlasTexture).region = _short_cut_image_region
	else:
		_shortcut_icon.hide()

func _set_button_state(val:ButtonState) -> void:
	if button_state == ButtonState.PRESSED && _rich_text_label:
		_rich_text_label.position.y -= 1
	super._set_button_state(val)
	if !_rich_text_label:
		return
	_set_text_color(val)
	match button_state:
		ButtonState.NORMAL:
			_border.region_rect.position = Vector2(0, 0)
		ButtonState.PRESSED:
			_border.region_rect.position = Vector2(16, 0)
			_rich_text_label.position.y += 1
		ButtonState.HOVERED:
			_border.region_rect.position = Vector2(32, 0)
		ButtonState.DISABLED:
			_border.region_rect.position = Vector2(0, 16)
		ButtonState.SELECTED:
			_border.region_rect.position = Vector2(16, 16)
			
func _set_highlighted(val:bool) -> void:
	super._set_highlighted(val)
	if !_animation_player:
		return
	if val:
		_animation_player.play("highlight")
	else:
		_animation_player.play("RESET")

func _set_localization_text_key(val:String) -> void:
	localization_text_key = val
	rich_text = tr(localization_text_key)

func _set_text_color(bs:ButtonState) -> void:
	var color := Constants.BUTTON_NORMAL_COLOR
	match bs:
		ButtonState.NORMAL:
			color = Constants.BUTTON_NORMAL_COLOR
		ButtonState.PRESSED:
			color = Constants.BUTTON_PRESSED_COLOR
		ButtonState.HOVERED:
			color = Constants.BUTTON_HOVERED_COLOR
		ButtonState.DISABLED:
			color = Constants.BUTTON_DISABLED_COLOR
		ButtonState.SELECTED:
			color = Constants.BUTTON_SELECTED_COLOR
	_rich_text_label.add_theme_color_override("default_color", color)
