class_name PlayerStateHeal
extends PlayerState

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")

@onready var player_heal_audio: AudioStreamPlayer2D = %PlayerHealAudio

func enter() -> void:
	super.enter()
	player.player_sprite.play_hurt()
	var popup:PopupLabel = POPUP_LABEL_SCENE.instantiate()
	popup.bump_direction = PopupThing.BumpDirection.UP
	var value:int = params.get("value", 0)
	assert(value >= 0, "Value must be negative")
	var popup_text:String = str(value)
	var color:Color = Constants.HP_INCREASE_COLOR
	popup.setup(popup_text, color, 10)
	Events.request_display_popup_things.emit(popup, 20, 5, Player.POPUP_SHOW_TIME, Player.POPUP_DESTROY_TIME, Util.get_node_canvas_position(player.player_sprite))
	player_heal_audio.play()
	exit("")
