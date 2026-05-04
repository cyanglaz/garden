class_name Main
extends Node2D

const MENU_SCENE := preload("res://scenes/menu/main_menu.tscn")
const LOADING_SCREEN_SCENE := preload("res://scenes/GUI/loading/loading_screen.tscn")
const GAME_SESSION := preload("res://scenes/main_game/main_game.tscn")

var current_scene: Node
static var _weak_main: WeakRef

static func weak_main() -> WeakRef:
	return _weak_main

func _ready() -> void:
	_weak_main = weakref(self)
	show_menu()

func show_menu() -> void:
	change_to(MENU_SCENE.instantiate())

func show_game_session() -> void:
	var fade_canvas := await _fade_to_black()
	change_to(GAME_SESSION.instantiate())
	await get_tree().process_frame
	fade_canvas.queue_free()

func _fade_to_black() -> CanvasLayer:
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	var overlay := ColorRect.new()
	overlay.color = Color.BLACK
	overlay.modulate.a = 0.0
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)
	add_child(canvas)
	var tween := Util.create_scaled_tween(overlay)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.4) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	return canvas

func load_scene_with_loading_screen(next_scene_path: String) -> void:
	var loading_scene := LOADING_SCREEN_SCENE.instantiate() as LoadingScreen
	loading_scene.next_scene_path = next_scene_path
	change_to(loading_scene)

func change_to(scene: Node) -> void:
	add_child(scene)
	if current_scene:
		current_scene.queue_free()
	current_scene = scene
