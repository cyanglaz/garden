class_name GUIEnemy
extends VBoxContainer

const BOSS_SCENE_PREFIX := "res://scenes/GUI/combat_main/enemy/boss/gui_boss_%s.tscn"
const DEFAULT_BOSS_SCENE_PATH := "res://scenes/GUI/combat_main/enemy/boss/gui_boss.tscn"

@onready var boss_container: PanelContainer = %BossContainer

var _boss_instance:GUIBoss = null

func update_with_combat(combat:CombatData, combat_main:CombatMain) -> void:
	if combat.combat_type != CombatData.CombatType.BOSS:
		boss_container.hide()
		return
	var boss_id = combat.boss_data.id
	var boss_scene_path := BOSS_SCENE_PREFIX % boss_id
	var boss_scene:PackedScene = null
	if ResourceLoader.exists(boss_scene_path):
		boss_scene = load(boss_scene_path)
	else:
		boss_scene = load(DEFAULT_BOSS_SCENE_PATH)
	_boss_instance = boss_scene.instantiate()
	boss_container.add_child(_boss_instance)
	_boss_instance.update_with_boss_data(combat.boss_data, combat_main)

func apply_boss_actions(hook_type:GUIBoss.HookType) -> void:
	if _boss_instance:
		if _boss_instance.has_hook(hook_type):
			await _boss_instance.handle_hook(hook_type)
