class_name GUIChestMain
extends CanvasLayer

signal trinket_reward_selected()
signal skipped()

const BACKGROUND_SHOW_DELAY_TIME := 0.3

@onready var gui_chest_reward_container: GUIChestRewardContainer = %GUIChestRewardContainer
@onready var gui_overlay_background: ColorRect = %GUIOverlayBackground
@onready var title_label: Label = %TitleLabel
@onready var gui_skip_button: GUISkipButton = %GUISkipButton

func _ready() -> void:
	gui_overlay_background.hide()
	title_label.text = Util.get_localized_string("CHEST_MAIN_TITLE_TEXT")
	gui_skip_button.hide()
	title_label.hide()
	gui_skip_button.pressed.connect(_on_skip_button_pressed)
	gui_chest_reward_container.trinket_reward_selected.connect(_on_trinket_reward_selected)

func spawn_trinket(trinket_data: TrinketData, spawn_position: Vector2) -> void:
	title_label.hide()
	Util.create_scaled_timer(BACKGROUND_SHOW_DELAY_TIME).timeout.connect(func() -> void:
		gui_overlay_background.show()
	)
	await gui_chest_reward_container.spawn_trinket(trinket_data, spawn_position)
	gui_skip_button.show()
	title_label.show()

func _on_skip_button_pressed() -> void:
	skipped.emit()

func _on_trinket_reward_selected() -> void:
	trinket_reward_selected.emit()
