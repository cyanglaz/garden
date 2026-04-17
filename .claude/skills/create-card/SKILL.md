---
name: create-card
description: Create a card based on the description in res:///csv/cards.csv
---

When creating plan, also include:

1. **The name and id of the card at the start of the plan view** , this is for me to confirm you are implementing the correct card.
2. **A complete code diff**
3. **Remove old plan for the previously implemented card**. Only show plans for the card you are actively working on right now.

When deciding which card to implement, following the below priority:

1. I specify the id or name of the card to implement.
2. Implement the next card in the csv that has not been implemented. Refer to the implemented column. If the card code exists and the implemented column says NO (or vice versa), there might be a data mismatch, ask me to confirm.

When implement a card, also consider:

0. Before implement a new card, always pull to make sure update from me is included.
1. If a card's effect can be implement with actions, use actions.
2. If a card's effect cannot be implemented with actions, use script.
3. If a card's effect is a power, follow other power cards implementations.
	- create a power tres file
	- create a power script
	- create a player upgrade scene
4. Add the card's tres file to main_game scene so i can test directly
5. **Localization:** Add `TOOL_<UPPERCASE_ID>_NAME` and 
	- If the tool must be implemented with a script, add `TOOL_<UPPERCASE_ID>_DESCRIPTION` entries to `resources/localization/localization.csv`. Follow the key pattern and description token format (e.g. `{resource:light}`, `{resource:water}`) used by existing card entries.
6. Cards's tres file should be under purchasable unless I specify.
7. **Card tests:**
   - For cards that utilize a player status, add a player status test.
   - For cards that utilize a tool_script, create a test file at `tests/gut_tests/gameplay/cards/test_player_card_<id>.gd`. 
   - For action only cards, do not add tests.
9. **Clear the plan doc** after finishing implementation: overwrite `/root/.claude/plans/<xxx>.md` with only the new card's plan content, removing all stale entries from previously implemented cards.
