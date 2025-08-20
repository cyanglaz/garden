class_name Main
extends Node2D

const MENU_SCENE := preload("res://scenes/GUI/menu/gui_main_menu.tscn")
const LOADING_SCREEN_SCENE := preload("res://scenes/GUI/loading/loading_screen.tscn")
const GAME_SESSION := preload("res://scenes/main_game/main_game.tscn")

var _current_scene:Node
static var _weak_main:WeakRef

static func weak_main() -> WeakRef:
	return _weak_main

func _ready():
	_weak_main = weakref(self)
	show_menu()

func show_menu():
	var menu = MENU_SCENE.instantiate()
	_load_scene(menu)

func show_game_session():
	pass

func load_scene_with_loading_screen(next_scene_path:String):
	var loading_scene = LOADING_SCREEN_SCENE.instantiate()
	loading_scene.next_scene_path = next_scene_path
	_load_scene(loading_scene)

func _load_scene(scene:Node):
	add_child.call_deferred(scene)
	if _current_scene:
		_current_scene.queue_free.call_deferred()
	set_deferred("_current_scene", scene)
