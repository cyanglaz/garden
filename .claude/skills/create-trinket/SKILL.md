---
name: create-trinket
description: Create a trinket based on the description in res:///csv/trinkets.csv
---

When creating plan, also include:

1. **The name and id of the trinket at the start of the plan view** , this is for me to confirm you are implementing the correct trinket.
2. **A complete code diff**

When deciding which trinket to implement, following the below priority:

1. I specify the id or name of the trinket to implement.
2. Implement the next trinket in the csv that has not been implemented. Refer to the implemented column. If the trinket code exists and the implemented column says NO (or vice versa), there might be a data mismatch, ask me to confirm.

When implement a trinket, also include:

1. **An empty aseprite file** Under res:///resource/sprites/GUI/icons/trinkets/, follow the naming convension of icon_<trinket_id>.aseprite
2. **Trinket tests:** When implementing a new trinket, also create a matching test file at `tests/gut_tests/gameplay/trinkets/test_player_trinket_<id>.gd`. Test the `has_*_hook` conditionals; see existing trinket tests for the pattern.
3. Add the trinket's tres file to main_game scene so i can test directly
4. Before implement a new trinket, always pull to make sure update from me is included.