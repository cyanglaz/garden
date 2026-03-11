extends ToolScript

# Test fixture – used by unit tests for ToolData (id = "test_fixture").
# Returns false for both field-action methods since all behaviour is
# defined by ActionData entries, not by script overrides.

func has_field_action() -> bool:
	return false

func need_select_field() -> bool:
	return false
