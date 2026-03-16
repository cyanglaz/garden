extends GutTest

# Tests for player status hook predicates.
# Only _has_*_hook() logic is tested here — pure predicate behaviour
# that does not require Plant, Player, or a live CombatMain scene.

# ----- Lightweight stub for Sustainability _has_activation_hook -----

class FakeDeck:
	var hand: Array = []

class FakeToolManager:
	var tool_deck := FakeDeck.new()

class FakeCombatMain:
	var tool_manager := FakeToolManager.new()

# ----- Helpers -----

func _make_tool(id: String, energy_cost: int = 1) -> ToolData:
	var td := ToolData.new()
	td.id = id
	td.energy_cost = energy_cost
	return td

# ----- Stun -----

func test_stun_has_prevent_movement_hook() -> void:
	var s := add_child_autofree(PlayerStatusStun.new())
	assert_true(s.has_prevent_movement_hook())

# ----- Regenerator -----

func test_regen_hook_true_for_momentum_negative_diff() -> void:
	var s := add_child_autofree(PlayerStatusRegenerator.new())
	assert_true(s.has_stack_update_hook(null, "momentum", -1))

func test_regen_hook_false_for_momentum_zero_diff() -> void:
	var s := add_child_autofree(PlayerStatusRegenerator.new())
	assert_false(s.has_stack_update_hook(null, "momentum", 0))

func test_regen_hook_false_for_momentum_positive_diff() -> void:
	var s := add_child_autofree(PlayerStatusRegenerator.new())
	assert_false(s.has_stack_update_hook(null, "momentum", 1))

func test_regen_hook_false_for_other_status_negative_diff() -> void:
	var s := add_child_autofree(PlayerStatusRegenerator.new())
	assert_false(s.has_stack_update_hook(null, "water", -1))

# ----- Overclock -----

func test_overclock_draw_hook_returns_true() -> void:
	var s := add_child_autofree(PlayerStatusOverclock.new())
	assert_true(s.has_draw_hook(null, []))

# ----- Refraction -----

func test_refraction_water_hook_true_for_positive_diff() -> void:
	var s := add_child_autofree(PlayerRefraction.new())
	assert_true(s.has_target_plant_water_update_hook(null, null, 1))

func test_refraction_water_hook_false_for_zero_diff() -> void:
	var s := add_child_autofree(PlayerRefraction.new())
	assert_false(s.has_target_plant_water_update_hook(null, null, 0))

func test_refraction_water_hook_false_for_negative_diff() -> void:
	var s := add_child_autofree(PlayerRefraction.new())
	assert_false(s.has_target_plant_water_update_hook(null, null, -1))

# ----- Sustainability -----

func test_sustainability_hand_hook_true_with_runoff_card() -> void:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	assert_true(s.has_card_added_to_hand_hook([_make_tool("runoff")]))

func test_sustainability_hand_hook_false_without_runoff() -> void:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	assert_false(s.has_card_added_to_hand_hook([_make_tool("watering_can")]))

func test_sustainability_hand_hook_false_for_empty_array() -> void:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	assert_false(s.has_card_added_to_hand_hook([]))

func test_sustainability_activation_hook_true_with_runoff_in_hand() -> void:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	var cm := FakeCombatMain.new()
	cm.tool_manager.tool_deck.hand = [_make_tool("runoff")]
	assert_true(s.has_activation_hook(cm))

func test_sustainability_activation_hook_false_with_empty_hand() -> void:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	var cm := FakeCombatMain.new()
	cm.tool_manager.tool_deck.hand = []
	assert_false(s.has_activation_hook(cm))

# ----- Contrail -----

func test_contrail_player_move_hook_returns_true() -> void:
	var s := add_child_autofree(PlayerStatusContrail.new())
	assert_true(s.has_player_move_hook(null))

# ----- Condensation -----

func test_condensation_discard_hook_returns_true() -> void:
	var s := add_child_autofree(PlayerStatusCondensation.new())
	assert_true(s.has_discard_hook(null, []))

# ----- CleanEnergy -----

func test_clean_energy_hook_true_for_zero_energy_cost() -> void:
	var s := add_child_autofree(PlayerStatusCleanEnergy.new())
	assert_true(s.has_tool_application_hook(null, _make_tool("solar_panel", 0)))

func test_clean_energy_hook_false_for_nonzero_energy_cost() -> void:
	var s := add_child_autofree(PlayerStatusCleanEnergy.new())
	assert_false(s.has_tool_application_hook(null, _make_tool("watering_can", 1)))
