class_name GUIPower
extends PanelContainer

const NORMAL_COLOR := Constants.COLOR_BEIGE_3
const HIGHLIGHT_COLOR := Constants.COLOR_BEIGE_2
const SELECTED_COLOR := Constants.COLOR_BEIGE_1

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _background: NinePatchRect = %Background
@onready var _disable_cover: NinePatchRect = %DisableCover

var button_state:GUIBasicButton.ButtonState: set = _set_button_state

func _ready() -> void:
	_set_button_state(GUIBasicButton.ButtonState.NORMAL)

func update_with_power_data(power:PowerData) -> void:
	_texture_rect.texture = load(Util.get_image_path_for_power_id(power.base_id))

func _set_button_state(bs:GUIBasicButton.ButtonState) -> void:
	button_state = bs
	_disable_cover.hide()
	match button_state:
		GUIBasicButton.ButtonState.NORMAL:
			_background.self_modulate = NORMAL_COLOR
		GUIBasicButton.ButtonState.DISABLED:
			_background.self_modulate = NORMAL_COLOR
			_disable_cover.show()
		GUIBasicButton.ButtonState.HOVERED:
			_background.self_modulate = HIGHLIGHT_COLOR
		GUIBasicButton.ButtonState.PRESSED:
			_background.self_modulate = NORMAL_COLOR
		GUIBasicButton.ButtonState.SELECTED:
			_background.self_modulate = NORMAL_COLOR
		_:
			assert(false, "Invalid button state: " + str(button_state))
