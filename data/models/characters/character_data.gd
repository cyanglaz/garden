class_name CharacterData
extends ThingData

const ICON_PATH_PREFIX := "res://resources/sprites/icons/characters/icon_"

var portrait_icon:Texture2D: get = _get_portrait_icon

func _get_portrait_icon() -> Texture2D:
	return load(ICON_PATH_PREFIX + id + ".png")
