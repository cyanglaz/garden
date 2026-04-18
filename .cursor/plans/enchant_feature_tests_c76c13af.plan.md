---
name: enchant feature tests
overview: Add focused unit tests in tests/gut_tests/data/ for the new enchant data model and database, and extend the existing ToolData tests to cover the new enchant_data field. GUI scenes are not unit-tested in this codebase, so the plan stays at the data-model layer to match existing patterns.
todos:
  - id: test-enchant-data
    content: Add tests/gut_tests/data/test_enchant_data.gd covering copy/get_duplicate/localization prefix
    status: pending
  - id: extend-tool-data
    content: Extend tests/gut_tests/data/test_tool_data.gd with enchant_data duplicate/independence cases
    status: pending
  - id: test-enchant-database
    content: Add tests/gut_tests/data/test_enchant_database.gd modeled on test_trinket_database_shop_roll.gd, seeding _datas directly
    status: pending
  - id: smoke-load-enchants
    content: Add a smoke test that iterates MainDatabase.enchant_database.get_all_datas() to validate all 8 .tres files
    status: pending
  - id: run-gut
    content: Run godot --headless -s addons/gut/gut_cmdln.gd and confirm all green
    status: pending
isProject: false
---

## Scope

Branch `enchant` introduces:

- New model: [data/models/tools/enchant_data.gd](data/models/tools/enchant_data.gd) (`EnchantData`)
- New database: [autoloads/database/enchant_database.gd](autoloads/database/enchant_database.gd) (`EnchantDatabase.roll_enchants`)
- New `enchant_data` field on [data/models/tools/tool_data.gd](data/models/tools/tool_data.gd) (handled in `copy()` / `get_duplicate()`)
- New event option script: [scenes/main_game/event/event_option_scripts/event_option_script_enchant.gd](scenes/main_game/event/event_option_scripts/event_option_script_enchant.gd)
- Lots of GUI pieces (`gui_enchant_main`, `gui_enchant_icon`, `gui_enchant_animation_container`, `gui_enchant_description`, `gui_enchant_tooltip`, etc.)

Tests will follow the existing patterns from [tests/gut_tests/data/test_tool_data.gd](tests/gut_tests/data/test_tool_data.gd) and [tests/gut_tests/data/test_trinket_database_shop_roll.gd](tests/gut_tests/data/test_trinket_database_shop_roll.gd). GUI scenes are intentionally out of scope (no precedent for instantiating GUI canvas layers in the existing test suite).

## Files to add / change

### 1. New: `tests/gut_tests/data/test_enchant_data.gd`

Unit-test `EnchantData` in isolation:

- `copy()` copies `rarity`
- `copy()` deep-copies `action_data` (mutating the dup's action does not affect original)
- `copy()` from another `EnchantData` produces an independent `action_data` instance
- `get_duplicate()` returns a new `EnchantData` instance (not the same object)
- `get_duplicate()` survives default `rarity = 0`
- `_get_localization_prefix()` returns `"ENCHANT_"`

Use the same `_original_resource_path` fixture trick from `test_tool_data.gd` to satisfy `ThingData` assertions.

### 2. Extend: `tests/gut_tests/data/test_tool_data.gd`

Add a new section "----- enchant_data -----" with:

- `test_duplicate_with_null_enchant_data_stays_null` - duplicating a tool whose `enchant_data` is null leaves the dup's `enchant_data` null
- `test_duplicate_copies_enchant_data` - duplicating a tool with an `EnchantData` produces a dup with non-null `enchant_data`, equal `rarity` / `action_data.type`
- `test_duplicate_enchant_data_is_independent` - mutating `dup.enchant_data.rarity` (or its `action_data.value`) does NOT affect the original
- `test_duplicate_enchant_data_is_separate_instance` - asserts the dup's `enchant_data` is a different object reference than the original's

These exercise the new lines in [data/models/tools/tool_data.gd](data/models/tools/tool_data.gd):

```71:73:data/models/tools/tool_data.gd
	if other_tool.enchant_data:
		enchant_data = other_tool.enchant_data.get_duplicate()
	_tool_script = null # Refresh tool script on copy
```

### 3. New: `tests/gut_tests/data/test_enchant_database.gd`

Modeled after `test_trinket_database_shop_roll.gd`. Construct `EnchantDatabase.new()` and seed `_datas` directly (the base class field is accessible) instead of loading from disk:

```gdscript
func _make_enchant(id: String, rarity_val: int) -> EnchantData:
    var ed := EnchantData.new()
    ed.set("_original_resource_path", "res://fake/%s.tres" % id)
    ed.id = id
    ed.rarity = rarity_val
    var ad := ActionData.new()
    ad.set("_original_resource_path", "res://fake/%s_action.tres" % id)
    ed.action_data = ad
    return ed

func _make_db(enchants: Array) -> EnchantDatabase:
    var db := EnchantDatabase.new()
    for e in enchants:
        db._datas[e.id] = e
    return db
```

Tests:

- `test_roll_zero_returns_empty`
- `test_roll_one_returns_one`
- `test_roll_n_returns_n_when_pool_large_enough`
- `test_roll_caps_at_pool_size_when_count_exceeds_available` - asks for more than pool has, expects `min(count, pool.size())`
- `test_roll_returns_unique_ids` - verifies `available.erase(chosen)` prevents duplicates
- `test_roll_returns_duplicates_not_originals` - returned objects are not the same instances as those in `_datas` (because of `chosen.get_duplicate()`)
- `test_roll_with_unknown_rarity_does_not_crash` - rarity outside `RARITY_WEIGHTS` (e.g. 5) still gets weight 1 via the `.get(e.rarity, 1)` fallback
- `test_roll_only_returns_enchants_from_pool` - every returned id is in the seeded pool

If the user prefers, an alternative is to refactor `roll_enchants(count)` to delegate to a static `_select_enchants(pool, count)` (mirroring `TrinketDatabase._select_shop_trinkets`) and test that static helper. Cleaner long-term, but a small production change. Will ask if uncertain.

### 4. (Optional) Smoke check that all 8 `data/enchants/*.tres` resources load

A single test in `test_enchant_database.gd`:

- `test_all_enchant_resources_load_via_main_database` - iterates `MainDatabase.enchant_database.get_all_datas()` and asserts each is a non-null `EnchantData` with non-null `action_data` and non-empty `id`. Catches typos / broken `.tres` files for the 8 new resources (`enchant_discard.tres`, `enchant_draw.tres`, `enchant_energy.tres`, `enchant_free_move.tres`, `enchant_light.tres`, `enchant_push_left.tres`, `enchant_push_right.tres`, `enchant_water.tres`).

## Out of scope

- GUI scene tests for `gui_enchant_main`, `gui_enchant_animation_container`, `gui_enchant_icon`, `gui_enchant_description`, `gui_enchant_tooltip` - no precedent in the test suite for canvas-layer / animation tests.
- `event_option_script_enchant.gd` - tightly coupled to `MainGame` and signal bus; no existing event-option-script tests to mirror.
- `gui_icon.gdshader` outline changes - shaders aren't unit-testable in GUT.
- CSV / `.tres` content changes (cards.csv, trinkets.csv, localization, palette tweaks).

## Latent issue worth surfacing (not a test task)

Signal arity mismatch: [scenes/GUI/event/events/enchant/gui_enchant_main.gd](scenes/GUI/event/events/enchant/gui_enchant_main.gd) declares `signal enchant_finished(old_tool_data:ToolData)` and emits with one arg, but both [scenes/GUI/town/gui_town_main.gd](scenes/GUI/town/gui_town_main.gd) (`_on_enchant_finished(tool_data, front_card_data, back_card_data)`) and [scenes/main_game/event/event_option_scripts/event_option_script_enchant.gd](scenes/main_game/event/event_option_scripts/event_option_script_enchant.gd) connect 3-arg handlers. This will fail at runtime when the forge/event flow fires. Worth fixing before tests; not something a unit test will catch on its own.

## Run / verify

```bash
godot --headless -s addons/gut/gut_cmdln.gd
```

Expectation: 3 new/extended files, ~25-30 new asserts, all green.