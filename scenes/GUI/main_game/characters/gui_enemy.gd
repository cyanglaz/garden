class_name GUIEnemy
extends PanelContainer

@onready var texture_rect: TextureRect = %TextureRect
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

var _weak_tooltip:WeakRef = weakref(null)
var animation_mode := false

func update_with_level_data(level_data:LevelData) -> void:
	if level_data.type == LevelData.Type.BOSS:
		show()
		texture_rect.texture = level_data.portrait_icon
		mouse_entered.connect(_on_mouse_entered.bind(level_data))
		mouse_exited.connect(_on_mouse_exited)
	else:
		hide()

func play_flying_sound() -> void:
	audio_stream_player_2d.play()

func _on_mouse_entered(level_data:LevelData) -> void:
	if !animation_mode:
		_weak_tooltip = weakref(Util.display_boss_tooltip(level_data, self, false, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited() -> void:
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)
