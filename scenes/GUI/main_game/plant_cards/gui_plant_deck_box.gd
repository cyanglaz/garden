class_name GUIPlantDeckBox
extends PanelContainer

const PLANT_CARD_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_card.tscn")
const PLANT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")

@onready var _plant_card_container: HBoxContainer = %PlantCardContainer

var _tooltip_id:String = ""

func update_with_plants(plants:Array[PlantData]) -> void:
	Util.remove_all_children(_plant_card_container)
	var index := 0
	for plant_data:PlantData in plants:
		var gui_plant_icon:GUIPlantCard = PLANT_CARD_SCENE.instantiate()
		_plant_card_container.add_child(gui_plant_icon)
		gui_plant_icon.update_with_plant_data(plant_data)
		gui_plant_icon.mouse_entered.connect(_on_mouse_entered.bind(index))
		gui_plant_icon.mouse_exited.connect(_on_mouse_exited.bind(index))
		index += 1

func get_plant_card_by_index(index:int) -> GUIPlantCard:
	return _plant_card_container.get_child(index)

func set_mode(mode:GUIPlantCard.Mode, indeces:Array) -> void:
	for i in indeces:
		var card:GUIPlantCard = _plant_card_container.get_child(i)
		if card.mode == GUIPlantCard.Mode.FINISHED:
			continue
		card.mode = mode

func remove_texture(indeces:Array) -> void:
	for i in indeces:
		var card:GUIPlantCard = _plant_card_container.get_child(i)
		card.remove_texture()

func get_icon_position(index:int) -> Vector2:
	return _plant_card_container.get_child(index).global_position

func _on_mouse_entered(index:int) -> void:
	var card:GUIPlantCard = _plant_card_container.get_child(index)
	var plant_data = card.gui_plant_icon.plant_data
	Events.update_hovered_data.emit(plant_data)
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.PLANT, plant_data, _tooltip_id, card, GUITooltip.TooltipPosition.BOTTOM))

func _on_mouse_exited(_index:int) -> void:
	Events.update_hovered_data.emit(null)
	Events.request_hide_tooltip.emit(_tooltip_id)
