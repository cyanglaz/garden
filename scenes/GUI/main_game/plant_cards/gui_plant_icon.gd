class_name GUIPlantIcon
extends PanelContainer

@onready var _background: NinePatchRect = %Background
@onready var _texture_rect: TextureRect = %TextureRect
@onready var _move_audio: AudioStreamPlayer2D = %MoveAudio

var has_outline:bool = false:set = _set_has_outline
var outline_color:Color = Constants.COLOR_WHITE:set = _set_outline_color
var plant_data:PlantData:get = _get_plant_data
var _weak_plant_data:WeakRef = weakref(null)

func update_with_plant_data(pd:PlantData) -> void:
	_weak_plant_data = weakref(pd)
	if plant_data:
		_background.region_rect.position = Util.get_plant_icon_background_region(plant_data, false)
		_texture_rect.texture = load(Util.get_icon_image_path_for_plant_id(plant_data.id))
	else:
		_texture_rect.texture = null
	
func play_move_sound() -> void:
	_move_audio.play()

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if _background:
		if has_outline:
			_background.material.set_shader_parameter("outline_size", 1)
			_background.material.set_shader_parameter("outline_color", outline_color)
		else:
			_background.material.set_shader_parameter("outline_size", 0)

func _set_outline_color(val:Color) -> void:
	outline_color = val
	if _background:
		_background.material.set_shader_parameter("outline_color", val)

func _get_plant_data() -> PlantData:
	return _weak_plant_data.get_ref()
