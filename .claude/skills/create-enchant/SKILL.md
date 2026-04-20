---
name: create-enchant
description: Create a enchant based on the description in res:///csv/enchants.csv
---

When creating plan, also include:

1. **The name and id of the enchant at the start of the plan view** , this is for me to confirm you are implementing the correct enchant.
2. **A complete code diff**
3. **Remove old plan for the previously implemented enchant**. Only show plans for the enchant you are actively working on right now.

When deciding which enchant to implement, following the below priority:

1. I specify the id or name of the enchant to implement.
2. Implement the next enchant in the csv that has not been implemented. Refer to the implemented column. If the enchant code exists and the implemented column says NO (or vice versa), there might be a data mismatch, ask me to confirm.

When implement a enchant, also remember:

1. **Localization:** Add `ENCHANT_<UPPERCASE_ID>_NAME` and 
	- If the tool must be implemented with a script, add `TOOL_<UPPERCASE_ID>_DESCRIPTION` entries to `resources/localization/localization.csv`. Follow the key pattern and description token format (e.g. `{resource:light}`, `{resource:water}`) used by existing enchant entries.
2. Enchant's tres file

