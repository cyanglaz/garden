---
name: create-event
description: Create a event based on the description in res:///csv/events.csv
---

When creating plan, also include:

1. **The id of the event at the start of the plan view** , this is for me to confirm you are implementing the correct event.
2. **A complete code diff**
3. **Remove old plan for the previously implemented event**. Only show plans for the event you are actively working on right now.

When implement a event, also include:

1. **event data file**, each event should have one event data .tres file.
2. **event option files**, each even option should have a event option .tres file.
3. **event option script**: 
	- I might ask you to create a generic option script for a given event option.
	- If I didn't ask you to create a new generic option, search for existing generic event option script that matches the behavior of the event, if you can find a match, reuse that script.
	- if no specific event option script found, create a new one with the name event_option_script_<option_id>.gd
5. **Localization:** Make sure to add localization for event narrative and and event option names. For trinket, cards or numbers, remember to use data to make them dynamic, not hard coding. For numbers, highlight them, for resources, use icon if possible.
7. **Clear the plan doc** after finishing implementation: overwrite `/root/.claude/plans/mighty-wobbling-crystal.md` with only the new event's plan content, removing all stale entries from previously implemented trinkets.