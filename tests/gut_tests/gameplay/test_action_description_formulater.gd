extends GutTest

# Tests for ActionDescriptionFormulator static methods.
# Field-status and player-status action types are safe to test because their
# descriptions come from real .tres data files (loaded by MainDatabase) rather
# than from localisation strings that may not be available in a headless run.

const FAKE_PATH := "res://fake/test_action.tres"

func _make_action(action_type: ActionData.ActionType, value: int = 1) -> ActionData:
	var ad := ActionData.new()
	ad.set("_original_resource_path", FAKE_PATH)
	ad.type = action_type
	ad.value = value
	ad.value_type = ActionData.ValueType.NUMBER
	ad.operator_type = ActionData.OperatorType.INCREASE
	return ad

# ----- get_special_name -----

func test_get_special_name_compost_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_name(ToolData.Special.COMPOST) is String)

func test_get_special_name_handy_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_name(ToolData.Special.HANDY) is String)

func test_get_special_name_nightfall_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_name(ToolData.Special.NIGHTFALL) is String)

func test_get_special_name_flip_front_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_name(ToolData.Special.FLIP_FRONT) is String)

func test_get_special_name_flip_back_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_name(ToolData.Special.FLIP_BACK) is String)

func test_get_special_name_reversible_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_name(ToolData.Special.REVERSIBLE) is String)

func test_get_special_names_are_all_distinct():
	var seen := []
	for special in ToolData.Special.values():
		var name := ActionDescriptionFormulator.get_special_name(special)
		assert_false(name in seen, "Duplicate special name: %s" % name)
		seen.append(name)

# ----- get_special_description -----

func test_get_special_description_compost_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_description(ToolData.Special.COMPOST) is String)

func test_get_special_description_handy_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_description(ToolData.Special.HANDY) is String)

func test_get_special_description_nightfall_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_description(ToolData.Special.NIGHTFALL) is String)

func test_get_special_description_flip_front_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_description(ToolData.Special.FLIP_FRONT) is String)

func test_get_special_description_flip_back_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_description(ToolData.Special.FLIP_BACK) is String)

func test_get_special_description_reversible_returns_string():
	assert_true(ActionDescriptionFormulator.get_special_description(ToolData.Special.REVERSIBLE) is String)

func test_get_special_descriptions_are_all_distinct():
	var seen := []
	for special in ToolData.Special.values():
		var desc := ActionDescriptionFormulator.get_special_description(special)
		assert_false(desc in seen, "Duplicate special description: %s" % desc)
		seen.append(desc)

# ----- get_raw_action_description -----

func test_get_raw_action_description_none_returns_empty():
	var ad := _make_action(ActionData.ActionType.NONE)
	assert_eq(ActionDescriptionFormulator.get_raw_action_description(ad, null), "")

func test_get_raw_action_description_pest_returns_field_status_description():
	var ad := _make_action(ActionData.ActionType.PEST)
	var result := ActionDescriptionFormulator.get_raw_action_description(ad, null)
	# raw description comes from the pest StatusData .tres file
	assert_true(result is String)
	assert_true(result.length() > 0)

func test_get_raw_action_description_drowned_returns_nonempty():
	var ad := _make_action(ActionData.ActionType.DROWNED)
	var result := ActionDescriptionFormulator.get_raw_action_description(ad, null)
	assert_true(result.length() > 0)

func test_get_raw_action_description_stun_returns_nonempty():
	var ad := _make_action(ActionData.ActionType.STUN)
	var result := ActionDescriptionFormulator.get_raw_action_description(ad, null)
	assert_true(result.length() > 0)

# ----- get_action_description: field status types -----
# These use descriptions from .tres files so do not depend on localisation.

func test_get_action_description_pest_is_nonempty():
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.PEST), null)
	assert_true(result.length() > 0)

func test_get_action_description_pest_contains_img_tag():
	# The pest description has a {resource:light} reference → produces an [img] tag
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.PEST), null)
	assert_true(result.contains("[img"))

func test_get_action_description_fungus_is_nonempty():
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.FUNGUS), null)
	assert_true(result.length() > 0)

func test_get_action_description_drowned_is_nonempty():
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.DROWNED), null)
	assert_true(result.length() > 0)

func test_get_action_description_buried_is_nonempty():
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.BURIED), null)
	assert_true(result.length() > 0)

func test_get_action_description_dew_is_nonempty():
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.DEW), null)
	assert_true(result.length() > 0)

func test_get_action_description_recycle_is_nonempty():
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.RECYCLE), null)
	assert_true(result.length() > 0)

func test_get_action_description_greenhouse_is_nonempty():
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.GREENHOUSE), null)
	assert_true(result.length() > 0)

func test_get_action_description_field_status_types_are_distinct():
	var field_status_types := ActionDescriptionFormulator.FIELD_STATUS_ACTION_TYPES
	var results := []
	for action_type in field_status_types:
		var result := ActionDescriptionFormulator.get_action_description(_make_action(action_type), null)
		assert_false(result in results, "Duplicate description for action type %s" % action_type)
		results.append(result)

# ----- get_action_description: player status types -----

func test_get_action_description_stun_is_nonempty():
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.STUN), null)
	assert_true(result.length() > 0)

func test_get_action_description_stun_stack_reflects_action_value():
	# The stun description contains {stack}, which is set to the action value.
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.STUN, 2), null)
	assert_true(result.contains("2"))

func test_get_action_description_stun_different_values_produce_different_results():
	var r1 := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.STUN, 1), null)
	var r2 := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.STUN, 3), null)
	assert_ne(r1, r2)

# ----- get_action_description: NONE type -----

func test_get_action_description_none_returns_string():
	var result := ActionDescriptionFormulator.get_action_description(_make_action(ActionData.ActionType.NONE), null)
	assert_true(result is String)
