class_name GUITrinketViewer
extends PanelContainer

const PLAYER_TRINKET_SCENE := preload("res://scenes/GUI/combat_main/trinkets/gui_player_trinket.tscn")

const RIGHT_MARGIN := 6
const TOP_MARGIN := 18

@onready var _grid_container: GridContainer = %GridContainer
@onready var _margin_container: MarginContainer = %MarginContainer

func _ready() -> void:
	position.y = TOP_MARGIN
	position.x = _get_hide_position_x()

func bind(trinket_manager: TrinketManager) -> void:
	trinket_manager.trinket_pool_updated.connect(_on_trinket_pool_updated)

func show_with_trinkets(trinkets: Array) -> void:
	show()
	_update_content(trinkets)
	_play_show_animation()

func animate_hide() -> void:
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "position:x", _get_display_x() + _get_panel_width(), Constants.HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _get_panel_width() -> float:
	var item_width = 0
	if _grid_container.get_child_count() > 0:
		var item := _grid_container.get_child(0) as Control
		item_width = item.get_combined_minimum_size().x
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
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "position:x", _get_display_x(), Constants.SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _update_content(trinkets: Array) -> void:
	Util.remove_all_children(_grid_container)
	for trinket_data in trinkets:
		var gui_trinket: GUIPlayerTrinket = PLAYER_TRINKET_SCENE.instantiate()
		_grid_container.add_child(gui_trinket)
		gui_trinket.show_stack = true
		gui_trinket.show_state = true
		gui_trinket.update_with_trinket_data(trinket_data)
		gui_trinket.tooltip_position = GUITooltip.TooltipPosition.BOTTOM_RIGHT

func _get_hide_position_x() -> float:
	return get_viewport_rect().size.x + RIGHT_MARGIN

func _on_trinket_pool_updated(trinkets: Array[TrinketData]) -> void:
	_update_content(trinkets)
	if visible:
		_play_show_animation()
