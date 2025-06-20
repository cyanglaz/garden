class_name GUIEnemyForecastBar
extends PanelContainer

const ENEMY_ICON_BUTTON_SCENE := preload("res://scenes/GUI/game_main/topbar/gui_enemy_icon_button.tscn")

@onready var _enemy_container: HBoxContainer = %EnemyContainer
@onready var _marker: TextureRect = %Marker

var _enemy_controller:EnemyController:get = _get_enemy_controller

var _weak_enemy_tooltip:WeakRef = weakref(null)
var _showing_index:int
var _weak_enemy_controller:WeakRef = weakref(null)

func _ready() -> void:
	_marker.hide()

func bind_enemy_controller(enemy_spawner:EnemyController) -> void:
	_weak_enemy_controller = weakref(enemy_spawner)
	enemy_spawner.enemy_populated.connect(_on_enemy_populated)
	enemy_spawner.current_enemy_updated.connect(_on_current_enemy_updated)

func _populate_enemies(enemies:Array[Enemy]) -> void:
	Util.remove_all_children(_enemy_container)
	var index:int = 0
	for enemy:Enemy in enemies:
		var enemy_icon_button:GUIEnemyIconButton = ENEMY_ICON_BUTTON_SCENE.instantiate()
		_enemy_container.add_child(enemy_icon_button)
		enemy_icon_button.bind_enemy(enemy)
		enemy_icon_button.action_evoked.connect(_on_enemy_icon_button_action_evoked.bind(enemy, index))
		index += 1
	
func _get_enemy_controller() -> EnemyController:
	return _weak_enemy_controller.get_ref()

func _on_enemy_icon_button_action_evoked(enemy:Enemy, index:int) -> void:
	if _weak_enemy_tooltip.get_ref() != null:
		_weak_enemy_tooltip.get_ref().queue_free()
		if _showing_index == index:
			return
	_weak_enemy_tooltip = weakref(Util.display_enemy_preview_tooltip(enemy, _enemy_container.get_child(index), false, GUITooltip.TooltipPosition.BOTTOM))
	_showing_index = index

func _on_enemy_populated() -> void:
	_populate_enemies(_enemy_controller.enemies)
	_marker.hide()

func _on_current_enemy_updated(index:int) -> void:
	if index == -1:
		_marker.hide()
	else:
		_marker.show()
		_marker.position.x = _enemy_container.get_child(index).position.x + _enemy_container.get_child(index).size.x/2 - _marker.size.x/2
		_marker.position.y = -2
		
func _input(event:InputEvent) -> void:
	if event.is_action("select"):
		if _weak_enemy_tooltip.get_ref() != null:
			var clicked_on_tooltip := Rect2(_weak_enemy_tooltip.get_ref().global_position, _weak_enemy_tooltip.get_ref().size).has_point(get_global_mouse_position())
			var showing_icon := _enemy_container.get_child(_showing_index)
			var clicked_on_icon := Rect2(showing_icon.global_position, showing_icon.size).has_point(get_global_mouse_position())
			if !clicked_on_tooltip && !clicked_on_icon:
				_weak_enemy_tooltip.get_ref().queue_free()
