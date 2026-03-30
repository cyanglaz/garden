---
name: create-trinket
description: Create a trinket based on the description in res:///csv/trinkets.csv
---

When creating plan, also include:

1. **The name and id of the trinket at the start of the plan view** , this is for me to confirm you are implementing the correct trinket.
2. **A complete code diff**
3. **Remove old plan for the previously implemented trinket**. Only show plans for the trinket you are actively working on right now.

When deciding which trinket to implement, following the below priority:

1. I specify the id or name of the trinket to implement.
2. Implement the next trinket in the csv that has not been implemented. Refer to the implemented column. If the trinket code exists and the implemented column says NO (or vice versa), there might be a data mismatch, ask me to confirm.

When implement a trinket, also include:

1. **An empty aseprite file** Under res:///resource/sprites/GUI/icons/trinkets/, follow the naming convension of icon_<trinket_id>.aseprite
2. **Trinket tests:** When implementing a new trinket, also create a matching test file at `tests/gut_tests/gameplay/trinkets/test_player_trinket_<id>.gd`. Test the `has_*_hook` conditionals; see existing trinket tests for the pattern.
3. Add the trinket's tres file to main_game scene so i can test directly
4. Before implement a new trinket, always pull to make sure update from me is included.
5. **Localization:** Add `TRINKET_<UPPERCASE_ID>_NAME` and `TRINKET_<UPPERCASE_ID>_DESCRIPTION` entries to `resources/localization/localization.csv`. Follow the key pattern and description token format (e.g. `{resource:light}`, `{resource:water}`) used by existing trinket entries.
6. **Draw hooks fire for all draws**, including the start-of-turn draw (which happens before `is_mid_turn` is set to `true`). All "after drawing a card" trinket effects must guard with `combat_main.is_mid_turn` in `_has_draw_hook`.
7. **Clear the plan doc** after finishing implementation: overwrite `/root/.claude/plans/mighty-wobbling-crystal.md` with only the new trinket's plan content, removing all stale entries from previously implemented trinkets.
8. Trinket's tres file should be under default unless i specify.