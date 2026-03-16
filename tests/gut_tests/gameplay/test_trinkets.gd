extends GutTest

# Tests for trinket hook predicates.
# Only _has_*_hook() logic is tested here — pure predicate behaviour
# that does not require Plant, Player, or a live CombatMain scene.

# ----- Lightweight stubs for SpareWing / SunShard -----

class FakeStatusContainer:
	var _momentum: int = 0
	func get_player_upgrade_stack(id: String) -> int:
		return _momentum if id == "momentum" else 0

class FakePlayer:
	var player_status_container := FakeStatusContainer.new()
	var current_field_index: int = 0
	var max_plants_index: int = 3

class FakeCombatMain:
	var player := FakePlayer.new()

# ----- SaltGrinder -----

func test_salt_grinder_start_turn_hook_returns_true() -> void:
	var t := add_child_autofree(PlayerTrinketSaltGrinder.new())
	assert_true(t.has_start_turn_hook(null))

func test_salt_grinder_has_no_end_turn_hook() -> void:
	var t := add_child_autofree(PlayerTrinketSaltGrinder.new())
	assert_false(t.has_end_turn_hook(null))

# ----- SpareWing -----

func test_spare_wing_start_turn_hook_true_when_no_momentum() -> void:
	var t := add_child_autofree(PlayerTrinketSpareWing.new())
	var cm := FakeCombatMain.new()
	cm.player.player_status_container._momentum = 0
	assert_true(t.has_start_turn_hook(cm))

func test_spare_wing_start_turn_hook_false_when_has_momentum() -> void:
	var t := add_child_autofree(PlayerTrinketSpareWing.new())
	var cm := FakeCombatMain.new()
	cm.player.player_status_container._momentum = 2
	assert_false(t.has_start_turn_hook(cm))

# ----- SunShard -----

func test_sun_shard_end_turn_hook_true_at_index_zero() -> void:
	var t := add_child_autofree(PlayerTrinketSunShard.new())
	var cm := FakeCombatMain.new()
	cm.player.current_field_index = 0
	cm.player.max_plants_index = 3
	assert_true(t.has_end_turn_hook(cm))

func test_sun_shard_end_turn_hook_true_at_max_index() -> void:
	var t := add_child_autofree(PlayerTrinketSunShard.new())
	var cm := FakeCombatMain.new()
	cm.player.current_field_index = 3
	cm.player.max_plants_index = 3
	assert_true(t.has_end_turn_hook(cm))

func test_sun_shard_end_turn_hook_false_at_middle_index() -> void:
	var t := add_child_autofree(PlayerTrinketSunShard.new())
	var cm := FakeCombatMain.new()
	cm.player.current_field_index = 1
	cm.player.max_plants_index = 3
	assert_false(t.has_end_turn_hook(cm))

func test_sun_shard_has_no_start_turn_hook() -> void:
	var t := add_child_autofree(PlayerTrinketSunShard.new())
	assert_false(t.has_start_turn_hook(null))

# ----- IceShard -----

func test_ice_shard_end_turn_hook_returns_true() -> void:
	var t := add_child_autofree(PlayerTrinketIceShard.new())
	assert_true(t.has_end_turn_hook(null))

func test_ice_shard_has_no_start_turn_hook() -> void:
	var t := add_child_autofree(PlayerTrinketIceShard.new())
	assert_false(t.has_start_turn_hook(null))
