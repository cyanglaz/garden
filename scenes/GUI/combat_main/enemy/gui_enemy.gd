class_name GUIEnemy
extends VBoxContainer

const BOSS_SCENE_PREFIX := "res://scenes/GUI/combat_main/enemy/boss/gui_boss_%s.tscn"
const DEFAULT_BOSS_SCENE_PATH := "res://scenes/GUI/combat_main/enemy/boss/gui_boss.tscn"

@onready var boss_container: PanelContainer = %BossContainer
@onready var gui_penalty_rate: GUIPenaltyRate = %GUIPenaltyRate

var _boss_instance:GUIBoss = null

func update_with_contract(contract:ContractData, combat_main:CombatMain) -> void:
	if contract.contract_type != ContractData.ContractType.BOSS:
		boss_container.hide()
		return
	var boss_id = contract.boss_data.id
	var boss_scene_path := BOSS_SCENE_PREFIX % boss_id
	var boss_scene:PackedScene = null
	if ResourceLoader.exists(boss_scene_path):
		boss_scene = load(boss_scene_path)
	else:
		boss_scene = load(DEFAULT_BOSS_SCENE_PATH)
	_boss_instance = boss_scene.instantiate()
	boss_container.add_child(_boss_instance)
	_boss_instance.update_with_boss_data(contract.boss_data, combat_main)

func update_penalty(penalty:int) -> void:
	gui_penalty_rate.update_penalty(penalty)

func apply_boss_actions(hook_type:GUIBoss.HookType) -> void:
	if _boss_instance:
		if _boss_instance.has_hook(hook_type):
			await _boss_instance.handle_hook(hook_type)
