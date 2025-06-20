class_name GUIAllDeckDisplay
extends Control

@onready var gui_draw_pile_display: GUIPileDisplay = %GUIDrawPileDisplay
@onready var gui_overlay_background: ColorRect = %GUIOverlayBackground

func _ready() -> void:
	gui_overlay_background.gui_input.connect(_on_overlay_background_gui_input)

func update_with_pool(pool:Array[BingoBallData]) -> void:
	gui_draw_pile_display.update_with_pool(pool)

func show_with_pool(pool:Array[BingoBallData]) -> void:
	visible = true
	update_with_pool(pool)
	PauseManager.try_pause()

func animate_hide() -> void:
	visible = false
	PauseManager.try_unpause()


func _on_overlay_background_gui_input(event:InputEvent) -> void:
	if event.is_action_pressed("select"):
		animate_hide()
