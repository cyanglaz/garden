class_name GUITrinketViewer
extends PanelContainer

const PLAYER_TRINKET_SCENE := preload("res://scenes/GUI/combat_main/trinkets/gui_player_trinket.tscn")

@onready var _grid_container: GridContainer = %GridContainer

func show_with_trinkets(trinkets: Array) -> void:
	show()
	Util.remove_all_children(_grid_container)
	for trinket_data in trinkets:
		var gui_trinket: GUIPlayerTrinket = PLAYER_TRINKET_SCENE.instantiate()
		_grid_container.add_child(gui_trinket)
		gui_trinket.update_with_trinket_data(trinket_data)
		gui_trinket.tooltip_position = GUITooltip.TooltipPosition.BOTTOM_RIGHT
	_play_show_animation()

func _play_show_animation() -> void:
	await get_tree().process_frame
	var display_x := position.x
	position.x = display_x + size.x
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "position:x", display_x, Constants.SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func animate_hide() -> void:
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "position:x", position.x + size.x, Constants.HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
