class_name PlayerStateDecreaseEnergy
extends PlayerState

const POPUP_LABEL_ICON_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label_icon.tscn")

@onready var decrease_energy_audio: AudioStreamPlayer2D = %DecreaseEnergyAudio
@onready var energy_decrease_particle: GPUParticles2D = %EnergyDecreaseParticle

func enter() -> void:
	super.enter()
	player.player_sprite.play_hurt()
	energy_decrease_particle.restart()
	decrease_energy_audio.play()
	var value:int = params.get("value", 0)
	assert(value >= 0, "Value must be positive")
	var popup:PopupLabelIcon = POPUP_LABEL_ICON_SCENE.instantiate()
	var color:Color = Constants.ENERGY_DECREASE_COLOR
	popup.setup(str("-",value), color, load(Util.get_image_path_for_resource_id(Util.get_action_id_with_action_type(ActionData.ActionType.ENERGY))))
	Events.request_display_popup_things.emit(popup, 20, 5, Player.POPUP_SHOW_TIME, Player.POPUP_DESTROY_TIME, Util.get_node_canvas_position(player.player_sprite))
	exit("")
