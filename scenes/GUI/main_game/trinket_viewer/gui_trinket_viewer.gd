class_name GUITrinketViewer
extends PanelContainer

const PLAYER_TRINKET_SCENE := preload("res://scenes/GUI/combat_main/trinkets/gui_player_trinket.tscn")

const RIGHT_MARGIN := 6

@onready var _grid_container: GridContainer = %GridContainer
@onready var _margin_container: MarginContainer = %MarginContainer

func bind(trinket_manager: TrinketManager) -> void:
	trinket_manager.trinket_pool_updated.connect(_on_trinket_pool_updated)

func show_with_trinkets(trinkets: Array) -> void:
	show()
	_update_content(trinkets)
	_play_show_animation()

func _update_content(trinkets: Array) -> void:
	Util.remove_all_children(_grid_container)
	for trinket_data in trinkets:
		var gui_trinket: GUIPlayerTrinket = PLAYER_TRINKET_SCENE.instantiate()
		_grid_container.add_child(gui_trinket)
		gui_trinket.update_with_trinket_data(trinket_data)
		gui_trinket.tooltip_position = GUITooltip.TooltipPosition.BOTTOM_RIGHT

func _on_trinket_pool_updated(trinkets: Array[TrinketData]) -> void:
	_update_content(trinkets)
	if visible:
		position.x = _get_display_x()

func _get_panel_width() -> float:
	var item := _grid_container.get_child(0) as Control
	var item_width := item.get_combined_minimum_size().x
	var h_sep := _grid_container.get_theme_constant("h_separation")
	var margin_h := _margin_container.get_theme_constant("margin_left") \
				+ _margin_container.get_theme_constant("margin_right")
	var true_number_of_columns:int = min(_grid_container.columns, _grid_container.get_child_count())
	return true_number_of_columns * item_width \
			+ (_grid_container.columns - 1) * h_sep \
			+ margin_h

func _get_display_x() -> float:
	return get_viewport_rect().size.x - _get_panel_width() - RIGHT_MARGIN

func _play_show_animation() -> void:
	var panel_width := _get_panel_width()
	var display_x := _get_display_x()
	position.x = display_x + panel_width
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "position:x", display_x, Constants.SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func animate_hide() -> void:
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "position:x", _get_display_x() + _get_panel_width(), Constants.HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
