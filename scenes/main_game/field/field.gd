class_name Field
extends Node2D

const SELECTION_ARROW_Y_OFFSET := 16

@export var size := 0:set = _set_size

@onready var field_land: FieldLand = %FieldLand
@onready var _gui_field_button: GUIBasicButton = %GUIFieldButton
@onready var _gui_field_selection_arrow: GUIFieldSelectionArrow = %GUIFieldSelectionArrow
@warning_ignore("unused_private_class_variable")
@onready var _container: Node2D = %Container
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _water_droplet_emitter: WaterDropletEmitter = %WaterDropletEmitter
@onready var _light_occluder_2d: LightOccluder2D = %LightOccluder2D

var land_width: get = _get_land_width

signal field_pressed()
signal field_hovered(hovered:bool)

func _ready() -> void:
	_gui_field_selection_arrow.indicator_state = GUIFieldSelectionArrow.IndicatorState.HIDE
	_gui_field_button.state_updated.connect(_on_gui_field_button_state_updated)
	_gui_field_button.pressed.connect(_on_plant_button_pressed)
	_gui_field_button.mouse_entered.connect(_on_gui_plant_button_mouse_entered)
	_gui_field_button.mouse_exited.connect(_on_gui_plant_button_mouse_exited)
	_container.child_entered_tree.connect(_on_container_child_entered_tree)
	_set_size(size)

func toggle_selection_indicator(indicator_state:GUIFieldSelectionArrow.IndicatorState) -> void:
	_gui_field_selection_arrow.indicator_state = indicator_state

#region events

func _on_gui_field_button_state_updated(state: GUIBasicButton.ButtonState) -> void:
	match state:
		GUIBasicButton.ButtonState.NORMAL, GUIBasicButton.ButtonState.DISABLED, GUIBasicButton.ButtonState.SELECTED, GUIBasicButton.ButtonState.PRESSED:
			field_land.has_outline = false
		GUIBasicButton.ButtonState.HOVERED:
			field_land.has_outline = true

func _on_gui_plant_button_mouse_entered() -> void:
	field_hovered.emit(true)

func _on_gui_plant_button_mouse_exited() -> void:
	field_hovered.emit(false)

func _on_plant_button_pressed() -> void:
	_animation_player.play("dip")
	field_pressed.emit()

func _on_dip_down() -> void:
	# Called in animation player
	_water_droplet_emitter.emit_droplets()

func _on_container_child_entered_tree(child: Node) -> void:
	var child_sprite:AnimatedSprite2D
	for finding_node in child.get_children():
		if finding_node is AnimatedSprite2D:
			child_sprite = finding_node
			break
	assert(child_sprite, "Children sprite not found")
	var sprite_frames:SpriteFrames = child_sprite.sprite_frames
	var current_animation:StringName = child_sprite.animation
	var frame_texture:Texture2D = sprite_frames.get_frame_texture(current_animation, 0)
	var image := frame_texture.get_image()
	var used_rect := image.get_used_rect()
	var pixel_height := used_rect.size.y
	_gui_field_selection_arrow.position.y = - pixel_height - SELECTION_ARROW_Y_OFFSET

func _get_land_width() -> float:
	return field_land.width

func _set_size(val:int) -> void:
	size = val
	if field_land:
		field_land.size = size
		_water_droplet_emitter.droplet_position_range = (size+2) * FieldLand.CELL_SIZE.x
		_water_droplet_emitter.number_of_droplets = (size+2) * 4 # 4 droplets per cell
		_gui_field_button.size.x = (size + 2) * FieldLand.CELL_SIZE.x
		_gui_field_button.position.x = - (size+2) * FieldLand.CELL_SIZE.x/2

		var polygon:PackedVector2Array = PackedVector2Array()
		polygon.append(Vector2(-(size+2) * FieldLand.CELL_SIZE.x/2, 0))
		polygon.append(Vector2((size+2) * FieldLand.CELL_SIZE.x/2, 0))
		polygon.append(Vector2((size+2) * FieldLand.CELL_SIZE.x/2, FieldLand.CELL_SIZE.y))
		polygon.append(Vector2(-(size+2) * FieldLand.CELL_SIZE.x/2, FieldLand.CELL_SIZE.y))
		_light_occluder_2d.occluder.polygon = polygon
		_light_occluder_2d.position.x = - (size+2) * FieldLand.CELL_SIZE.x/2
