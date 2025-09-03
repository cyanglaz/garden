class_name GUILevelButton
extends GUIBasicButton

enum IconState {
	NORMAL,
	CURRENT,
	FINISHED
}

const ICON_SIZE:= 13
const REGION_SIZE := Vector2(13, 13)

@onready var fill: TextureRect = %Fill
@onready var border: TextureRect = %Border

var icon_state:IconState = IconState.NORMAL: set = _set_icon_state

var _has_outline:bool = true: set = _set_has_outline
var _weak_level_data:WeakRef = weakref(null)

func update_with_level_data(level_data:LevelData) -> void:
	match level_data.type:
		LevelData.Type.MINION:
			(fill.texture as AtlasTexture).region.position.y = 0
			(border.texture as AtlasTexture).region.position.y = 0
		LevelData.Type.BOSS:
			(fill.texture as AtlasTexture).region.position.y = ICON_SIZE
			(border.texture as AtlasTexture).region.position.y = ICON_SIZE
	border.hide()
	
func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	_set_has_outline(true)

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	_set_has_outline(false)

func _set_has_outline(val:bool) -> void:
	_has_outline = val
	if val:
		border.show()
	else:
		border.hide()

func _get_level_data() -> LevelData:
	return _weak_level_data.get_ref()

func _set_icon_state(val:IconState) -> void:
	icon_state = val
	if val == IconState.NORMAL:
		(fill.texture as AtlasTexture).region.position.x = 0
	elif val == IconState.CURRENT:
		(fill.texture as AtlasTexture).region.position.x = ICON_SIZE
	elif val == IconState.FINISHED:
		(fill.texture as AtlasTexture).region.position.x = ICON_SIZE * 2
