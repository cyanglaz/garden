class_name GUIEnemy
extends PanelContainer

#@onready var texture_rect: TextureRect = %TextureRect
#@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
#
#var _weak_tooltip:WeakRef = weakref(null)
#var display_mode := false
#var library_mode := false
#var is_highlighted:bool = false:set = _set_is_highlighted
#var _weak_level_data:WeakRef = weakref(null)
#
#func _ready() -> void:
	#mouse_entered.connect(_on_mouse_entered)
	#mouse_exited.connect(_on_mouse_exited)
##
##func update_with_level_data(level_data:LevelData) -> void:
	##_weak_level_data = weakref(level_data)
	##if level_data.type == LevelData.Type.BOSS:
		##show()
		##texture_rect.texture = level_data.portrait_icon
	##else:
		##hide()
##
##func play_flying_sound() -> void:
	##audio_stream_player_2d.play()
##
##func _on_mouse_entered() -> void:
	##if _weak_level_data.get_ref().type != LevelData.Type.BOSS:
		##return
	##is_highlighted = true
	##if !display_mode:
		##Singletons.main_game.hovered_data = _weak_level_data.get_ref()
		##_weak_tooltip = weakref(Util.display_boss_tooltip(_weak_level_data.get_ref(), self, false, GUITooltip.TooltipPosition.LEFT))
##
##func _on_mouse_exited() -> void:
	##is_highlighted = false
	##if !library_mode && _weak_level_data.get_ref().type == LevelData.Type.BOSS:
		##Singletons.main_game.hovered_data = null
	##if _weak_tooltip.get_ref():
		##_weak_tooltip.get_ref().queue_free()
		##_weak_tooltip = weakref(null)
#
#func _set_is_highlighted(val:bool) -> void:
	#is_highlighted = val
	#if is_highlighted:
		#(texture_rect.material as ShaderMaterial).set_shader_parameter("blend_strength", 0.2)
	#else:
		#(texture_rect.material as ShaderMaterial).set_shader_parameter("blend_strength", 0.0)
