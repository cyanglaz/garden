class_name GUITrinketViewer
extends PanelContainer

const PLAYER_TRINKET_SCENE := preload("res://scenes/GUI/combat_main/trinkets/gui_player_trinket.tscn")

@onready var _grid_container: GridContainer = %GridContainer

var _display_y := 0.0

func _ready() -> void:
	_display_y = position.y

func show_with_trinkets(trinkets: Array) -> void:
	show()
	Util.remove_all_children(_grid_container)
	for trinket_data in trinkets:
		var gui_trinket: GUIPlayerTrinket = PLAYER_TRINKET_SCENE.instantiate()
		_grid_container.add_child(gui_trinket)
		gui_trinket.update_with_trinket_data(trinket_data)
	_play_show_animation()

func _play_show_animation() -> void:
	position.y = Constants.PENEL_HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "position:y", _display_y, Constants.SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func animate_hide() -> void:
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "position:y", Constants.PENEL_HIDE_Y, Constants.HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
