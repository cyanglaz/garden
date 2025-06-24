class_name GUIToolIcon
extends Control

const HIGHLIGHTED_OFFSET := 16

@onready var _background: NinePatchRect = %Background
@onready var _texture_rect: TextureRect = %TextureRect
# @onready var _border: NinePatchRect = %Border

var highlighted:bool:set = _set_highlighted

func update_with_tool_dat(tool_data:ToolData) -> void:
	if tool_data:
		_background.region_rect.position = Util.get_plant_icon_background_region(tool_data, false)
		_texture_rect.texture = load(Util.get_icon_image_path_for_tool_id(tool_data.id))
	else:
		_texture_rect.texture = null

func _set_highlighted(val:bool) -> void:
	highlighted = val
	if highlighted:
		_background.region_rect.position.y = HIGHLIGHTED_OFFSET
	else:
		_background.region_rect.position.y = 0
