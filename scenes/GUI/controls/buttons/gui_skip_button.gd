class_name GUISkipButton
extends GUIBasicButton

@export var stay_at_default_location:bool = true

@onready var _rich_text_label: RichTextLabel = %RichTextLabel
@onready var _gui_icon: GUIIcon = %GUIIcon
@onready var _border: NinePatchRect = %Border

func _ready() -> void:
	super._ready()
	_rich_text_label.text = Util.get_localized_string("ACTION_SKIP")
	if stay_at_default_location:
		self.position = get_parent().size - Vector2(Constants.SKIP_BUTTON_PADDING, Constants.SKIP_BUTTON_PADDING) - self.size

func _set_button_state(val:ButtonState) -> void:
	if button_state == ButtonState.PRESSED && _rich_text_label:
		_rich_text_label.position.y -= 1
		_gui_icon.position.y -= 1
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
			_gui_icon.position.y += 1
		ButtonState.HOVERED:
			_border.region_rect.position = Vector2(32, 0)
		ButtonState.DISABLED:
			_border.region_rect.position = Vector2(0, 16)
		ButtonState.SELECTED:
			_border.region_rect.position = Vector2(16, 16)


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
