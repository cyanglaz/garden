class_name EnemyController
extends Node

signal current_enemy_updated(index:int)
signal current_enemy_died()
signal enemy_populated()

const HP_ADJUSTMENT_PER_INDEX := 6
const FLOOR_TO_TRASH_COUNT := {
	0: 5,
	1: 5,
}
#const DRAWS_BEFORE_NEXT_ENEMY := 6

var enemies:Array[Enemy]
var enemy_index := 0
#var bench_index:int = 0
#var _benched_enemies:Array[Enemy]
#var _next_enemy_draw_count:int = DRAWS_BEFORE_NEXT_ENEMY

var _enemy_container:GUIEnemyContainer: get = _get_enemy_container
var _weak_enemy_container:WeakRef = weakref(null)
var _current_enemy:Enemy
#var _gui_enemy_process:GUIEnemyProcess: get = _get_gui_enemy_process
#var _weak_gui_enemy_process:WeakRef = weakref(null)

func bind_enemy_container(enemy_container:GUIEnemyContainer) -> void:
	_weak_enemy_container = weakref(enemy_container)

func get_current_enemy() -> Enemy:
	return _current_enemy

func get_active_enemies() -> Array[Enemy]:
	if !_current_enemy:
		return []
	var result:Array[Enemy]
	result.append(_current_enemy)
	#result.append_array(_benched_enemies)
	return result

func reset_all_active_enemies() -> void:
	for enemy:Enemy in get_active_enemies():
		enemy.animate_reset_all_attack_counters()

func handle_enemy_died() -> void:
	current_enemy_updated.emit(-1)
	#assert(enemy_index <= bench_index)
	enemy_index += 1
	#bench_index = maxi(bench_index, enemy_index)
	#if _benched_enemies.is_empty() && enemy_index < enemies.size() -1:
	#	await _animate_update_draws_left(DRAWS_BEFORE_NEXT_ENEMY)
	await _enemy_container.animate_current_enemy_died()

func spawn_enemy(test_override:CharacterData) -> void:
	if test_override:
		_current_enemy = Enemy.new(test_override)
		await _enemy_container.animate_spawn_enemy(_current_enemy)
	else:
		_current_enemy = enemies[enemy_index]
		await _enemy_container.animate_spawn_enemy(_current_enemy)
		#_update_benched_enemies()
		current_enemy_updated.emit(enemy_index)
		_current_enemy.combat_state = Enemy.CombatState.ACTIVE
	_current_enemy.died.connect(_on_current_enemy_died)

func populate_enemies(stage:int) -> void:
	enemies.clear()
	enemy_index = 0

	# populate trash enemies
	var trash_count:int = FLOOR_TO_TRASH_COUNT[stage]
	var type := EnemyData.Type.NORMAL
	var trashes:Array[EnemyData] = MainDatabase.enemy_database.roll_enemies(trash_count, stage, type)
	for i in trashes.size():
		var trash_data:EnemyData = trashes[i]
		trash_data.max_hp += HP_ADJUSTMENT_PER_INDEX * i
		var enemy:Enemy = Enemy.new(trash_data)
		enemy.combat_state = Enemy.CombatState.INACTIVE
		enemies.append(enemy)

	# boss
	var bosses:Array[EnemyData] = MainDatabase.enemy_database.roll_enemies(1, stage, EnemyData.Type.BOSS)
	var boss_data:EnemyData = bosses[0]
	enemies.append(Enemy.new(boss_data))
	enemy_populated.emit()

func _get_enemy_container() -> GUIEnemyContainer:
	return _weak_enemy_container.get_ref()

func _on_current_enemy_died() -> void:
	current_enemy_died.emit()

#func _get_gui_enemy_process() -> GUIEnemyProcess:
#	return _weak_gui_enemy_process.get_ref()

#func _update_benched_enemies() -> void:
#	_benched_enemies = enemies.slice(enemy_index + 1, bench_index + 1)
#	for enemy:Enemy in _benched_enemies:
#		enemy.combat_state = Enemy.CombatState.ACTIVE

#func _animate_update_draws_left(val:int) -> void:
#	_next_enemy_draw_count = val
#	await _gui_enemy_process.animate_update_draws_left(_next_enemy_draw_count)

#func bind_gui_enemy_process(gui_enemy_process:GUIEnemyProcess) -> void:
#	_weak_gui_enemy_process = weakref(gui_enemy_process)
	#_gui_enemy_process.set_draws_left(_next_enemy_draw_count)

#func handle_draw() -> void:
#	if enemy_index == enemies.size() -1:
#		return
#	await _animate_update_draws_left(_next_enemy_draw_count-1)
#	assert(_next_enemy_draw_count >= 0)
#	if _next_enemy_draw_count == 0:
#		if bench_index < enemies.size() - 1:
#			bench_index += 1
#			_update_benched_enemies()
#			await _enemy_container.animate_add_bench_enemy(_benched_enemies[_benched_enemies.size() - 1])
#		await _animate_update_draws_left(DRAWS_BEFORE_NEXT_ENEMY)
