class_name GUIPlantIcon
extends PanelContainer

const HIGHLIGHTED_OFFSET := 16

@onready var _background: NinePatchRect = %Background
@onready var _texture_rect: TextureRect = %TextureRect
# @onready var _border: NinePatchRect = %Border
@onready var _move_audio: AudioStreamPlayer2D = %MoveAudio

var highlighted:bool:set = _set_highlighted

func update_with_plant_data(plant_data:PlantData) -> void:
	if plant_data:
		_background.region_rect.position = Util.get_plant_icon_background_region(plant_data, false)
		_texture_rect.texture = load(Util.get_icon_image_path_for_plant_id(plant_data.id))
	else:
		_texture_rect.texture = null
	
func play_move_sound() -> void:
	_move_audio.play()

func _set_highlighted(val:bool) -> void:
	highlighted = val
	if highlighted:
		_background.region_rect.position.y = HIGHLIGHTED_OFFSET
	else:
		_background.region_rect.position.y = 0
