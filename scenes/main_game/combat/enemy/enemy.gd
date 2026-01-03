class_name Enemy
extends Node2D

const AREA_SIZE_PER_CURSE_PARTICLE := 5
const CURSE_PARTICLE_Y_OFFSET := 4.0
const ATTACK_ICON_CONTAINER_Y_OFFSET := 16.0
const ATTACK_ICON_CONTAINER_MIN_Y_OFFSET := -32.0

const ATTACK_ICON_PREFIX := "res://resources/sprites/GUI/icons/attack/icon_attack_%s.png"
const ATTACK_SCENE := preload("res://scenes/main_game/combat/enemy/attack/attack.tscn")
const GUI_ICON_SCENE := preload("res://scenes/GUI/utils/gui_icon.tscn")

@onready var enemy_particle: GPUParticles2D = %EnemyParticle
@onready var attack_icon_container: HBoxContainer = %AttackIconContainer
@onready var attacks_container: Node2D = $AttacksContainer

var _attack_datas:Array[AttackData] = []
var attacks:Array

func resize_enemy_particle(plant_sprite:AnimatedSprite2D) -> void:
	var sprite_frames:SpriteFrames = plant_sprite.sprite_frames
	var current_animation:StringName = plant_sprite.animation
	var frame_texture:Texture2D = sprite_frames.get_frame_texture(current_animation, 0)
	var image := frame_texture.get_image()
	var used_rect := image.get_used_rect()
	enemy_particle.process_material.emission_box_extents = Vector3(used_rect.size.x/2.0, used_rect.size.y/2.0, 1)
	var area_size :float = enemy_particle.process_material.emission_box_extents.x * enemy_particle.process_material.emission_box_extents.y
	var number_of_particles := area_size / AREA_SIZE_PER_CURSE_PARTICLE
	enemy_particle.amount = int(number_of_particles)
	enemy_particle.position.y = - used_rect.size.y/2.0 + CURSE_PARTICLE_Y_OFFSET
	attack_icon_container.position.y = max(- used_rect.size.y - 16, ATTACK_ICON_CONTAINER_MIN_Y_OFFSET)

func setup_with_attack_datas(attack_datas:Array[AttackData]) -> void:
	_attack_datas = attack_datas.duplicate()

func generate_next_attacks(plant:Plant, combat_main:CombatMain) -> void:
	Util.remove_all_children(attack_icon_container)
	Util.remove_all_children(attacks_container)
	attacks.clear()
	var selected_attack_data:AttackData = Util.unweighted_roll(_attack_datas, 1)[0] as AttackData
	var attack:Attack = ATTACK_SCENE.instantiate()
	attacks.append(attack)
	attacks_container.add_child(attack)
	
	print(ATTACK_ICON_PREFIX % Util.get_id_for_attack_type(selected_attack_data.attack_type))
	var attack_icon := load(ATTACK_ICON_PREFIX % Util.get_id_for_attack_type(selected_attack_data.attack_type))
	var gui_icon: GUIIcon = GUI_ICON_SCENE.instantiate()
	attack_icon_container.add_child(gui_icon)
	gui_icon.texture = attack_icon
	var target_positions:Array[Vector2] = []
	for target_position_index in selected_attack_data.target_positions:
		var target_index:int = plant.field.index + target_position_index
		var target_position:Vector2 = combat_main.plant_field_container.get_field(target_index).global_position - Vector2.UP * Player.POSITION_Y_OFFSET
		target_positions.append(target_position)
	attack.setup_with_attack_data.call_deferred(selected_attack_data, gui_icon.global_position, target_positions)
