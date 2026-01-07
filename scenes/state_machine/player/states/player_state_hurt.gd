class_name PlayerStateHurt
extends PlayerState

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")

@onready var player_hurt_audio: AudioStreamPlayer2D = %PlayerHurtAudio

func enter() -> void:
	super.enter()
	player.player_sprite.play_hurt()
	Events.request_camera_shake_effects.emit(0.5, Vector2(20, 20), 0.2, 1.0, 0)
	var popup:PopupLabel = POPUP_LABEL_SCENE.instantiate()
	popup.bump_direction = PopupThing.BumpDirection.UP
	var value:int = params.get("value", 0)
	assert(value < 0, "Value must be negative")
	var popup_text:String = str("-", value)
	var color:Color = Constants.HP_DECREASE_COLOR
	popup.setup(popup_text, color, 10)
	Events.request_display_popup_things.emit(popup, 20, 5, Player.POPUP_SHOW_TIME, Player.POPUP_DESTROY_TIME, Util.get_node_canvas_position(player.player_sprite))
	player_hurt_audio.play()
	exit("")
