class_name GUIPlantDeckBox
extends PanelContainer

enum Type {
	DRAW,
	DISCARD,
}

const PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")
const PLANT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")

@export var type:Type

@onready var _next_container: VBoxContainer = %NextContainer
@onready var _gui_plant_icon: GUIPlantIcon = %GUIPlantIcon

var _weak_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	_gui_plant_icon.mouse_entered.connect(_on_mouse_entered.bind(0))
	_gui_plant_icon.mouse_exited.connect(_on_mouse_exited.bind(0))

func bind_deck(deck:Deck) -> void:
	match type:
		Type.DRAW:
			_on_pool_updated(deck.draw_pool)
			deck.draw_pool_updated.connect(_on_pool_updated)
		Type.DISCARD:
			_on_pool_updated(deck.discard_pool)
			deck.discard_pool_updated.connect(_on_pool_updated)
			_next_container.hide()

func _on_pool_updated(pool:Array) -> void:
	if pool.is_empty():
		_gui_plant_icon.update_with_plant_data(null)
	else:
		_gui_plant_icon.update_with_plant_data(pool[0])
	Util.remove_all_children(_next_container)
	var index := 1
	for item in pool.slice(1, pool.size()):
		var gui_plant_icon:GUIPlantIcon = PLANT_ICON_SCENE.instantiate()
		_next_container.add_child(gui_plant_icon)
		gui_plant_icon.update_with_plant_data(item)
		gui_plant_icon.custom_minimum_size = _gui_plant_icon.custom_minimum_size * 0.8
		gui_plant_icon.size = gui_plant_icon.custom_minimum_size
		gui_plant_icon.mouse_entered.connect(_on_mouse_entered.bind(index))
		gui_plant_icon.mouse_exited.connect(_on_mouse_exited.bind(index))
		match type:
			Type.DRAW:
				gui_plant_icon.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			Type.DISCARD:
				gui_plant_icon.size_flags_horizontal = Control.SIZE_SHRINK_END
		index += 1

func _on_mouse_entered(index:int) -> void:
	match type:
		Type.DRAW:
			var plant_data:PlantData 
			var icon:GUIPlantIcon
			if index == 0:
				plant_data = _gui_plant_icon.plant_data
				icon = _gui_plant_icon
			else:
				icon = _next_container.get_child(index - 1)
				plant_data = icon.plant_data
			if plant_data:
				_weak_tooltip = weakref(Util.display_plant_tooltip(plant_data, icon, false, GUITooltip.TooltipPosition.RIGHT))
		Type.DISCARD:
			_next_container.show()

func _on_mouse_exited(_index:int) -> void:
	match type:
		Type.DRAW:
			if _weak_tooltip.get_ref():
				_weak_tooltip.get_ref().hide()
				_weak_tooltip = weakref(null)
		Type.DISCARD:
			_next_container.hide()
