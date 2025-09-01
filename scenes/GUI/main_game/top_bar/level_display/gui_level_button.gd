class_name GUILevelButton
extends GUIBasicButton

const MINION_ICON := preload("res://resources/sprites/icons/other/icon_level_minion.png")
const BOSS_ICON := preload("res://resources/sprites/icons/other/icon_level_boss.png")
const REGION_SIZE := Vector2(13, 13)

@onready var _texture_rect: TextureRect = %TextureRect

var _has_outline:bool = true: set = _set_has_outline
var _weak_level_data:WeakRef = weakref(null)

func update_with_level_data(level_data:LevelData) -> void:
	var texture := AtlasTexture.new()
	texture.region.size = REGION_SIZE
	match level_data.type:
		LevelData.Type.MINION:
			texture.atlas = MINION_ICON			
		LevelData.Type.BOSS:
			texture.atlas = BOSS_ICON
	_texture_rect.texture = texture
	
func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	_set_has_outline(true)

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	_set_has_outline(false)

func _set_has_outline(val:bool) -> void:
	_has_outline = val
	if val:
		(_texture_rect.texture as AtlasTexture).region.position = Vector2(13, 0)
	else:
		(_texture_rect.texture as AtlasTexture).region.position = Vector2(0, 0)

func _get_level_data() -> LevelData:
	return _weak_level_data.get_ref()
