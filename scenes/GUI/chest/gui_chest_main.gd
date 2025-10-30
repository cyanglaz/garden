class_name GUIChestMain
extends CanvasLayer

const BACKGROUND_SHOW_DELAY_TIME := 0.3

@onready var gui_chest_reward_container: GUIChestRewardContainer = %GUIChestRewardContainer
@onready var gui_overlay_background: ColorRect = $GUIOverlayBackground

func _ready() -> void:
	gui_overlay_background.hide()

func spawn_cards(number_of_cards:int, rarity:int, spawn_position:Vector2) -> void:
	Util.create_scaled_timer(BACKGROUND_SHOW_DELAY_TIME).timeout.connect(func () -> void:
		gui_overlay_background.show()
	)
	await gui_chest_reward_container.spawn_cards(number_of_cards, rarity, spawn_position)
