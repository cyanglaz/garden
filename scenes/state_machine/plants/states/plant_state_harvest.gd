class_name PlantStateHarvest
extends PlantState

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_labels/popup_label.tscn")

const GOLD_LABEL_OFFSET := Vector2.RIGHT * 12
const POPUP_LABEL_TIME := 0.5

@onready var _gold_audio: AudioStreamPlayer2D = %GoldAudio

func enter() -> void:
	super.enter()
	plant.harvest_started.emit()
	_gold_audio.play()
	var gold_label:PopupLabel = POPUP_LABEL_SCENE.instantiate()
	Singletons.main_game.add_control_to_overlay(gold_label)
	gold_label.global_position = Util.get_node_ui_position(gold_label, plant) + GOLD_LABEL_OFFSET
	var color:Color = Constants.COLOR_YELLOW2
	await gold_label.animate_show_and_destroy(str("+", plant.data.gold), 8, 6, POPUP_LABEL_TIME, POPUP_LABEL_TIME, color)
	plant.harvest_gold_gained.emit(plant.data.gold)
	plant.harvest_completed.emit()

func _get_animation_name() -> String:
	return "idle" + str("_", plant.stage)
