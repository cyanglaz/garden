class_name PlantStateHarvest
extends PlantState

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label_icon.tscn")
const GOLD_ICON := preload("res://resources/sprites/GUI/icons/resources/icon_gold.png")

const GOLD_LABEL_OFFSET := Vector2.RIGHT * 12
const POPUP_LABEL_TIME := 0.5

@onready var _gold_audio: AudioStreamPlayer2D = %GoldAudio

func enter() -> void:
	super.enter()
	plant.harvest_started.emit()
	await plant.field.status_manager.handle_harvest_gold_hooks(plant)
	await _gain_gold()
	await _handle_ability()

func _gain_gold() -> void:
	_gold_audio.play()
	var gold_label:PopupLabelIcon = POPUP_LABEL_SCENE.instantiate()
	Singletons.main_game.add_control_to_overlay(gold_label)
	gold_label.global_position = Util.get_node_ui_position(gold_label, plant) + GOLD_LABEL_OFFSET
	var color:Color = Constants.COLOR_YELLOW2
	gold_label.setup(str("+", plant.data.gold), color, GOLD_ICON)
	await gold_label.animate_show_and_destroy(8, 6, POPUP_LABEL_TIME, POPUP_LABEL_TIME)
	plant.harvest_gold_gained.emit(plant.data.gold)

func _handle_ability() -> void:
	await plant.trigger_ability(Plant.AbilityType.HARVEST, Singletons.main_game)
	_complete()

func _complete() -> void:
	plant.harvest_completed.emit()
	exit("")

func _get_animation_name() -> String:
	return "idle" + str("_", plant.stage)
