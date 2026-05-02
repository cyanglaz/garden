extends GutTest

const GUI_HP_SCENE := preload("res://scenes/GUI/main_game/top_bar/gui_hp.tscn")


func test_max_hp_update_rebuilds_and_refreshes_segments() -> void:
	var hp: GUIHP = GUI_HP_SCENE.instantiate()
	add_child_autofree(hp)
	await get_tree().process_frame

	var point := ResourcePoint.new()
	point.setup(1, 3)
	hp.bind_with_hp(point)

	point.max_value = 5

	var segment_container: HBoxContainer = hp.get_node("%SegmentContainer")
	assert_eq(segment_container.get_child_count(), 5)
	assert_false((segment_container.get_child(0) as GUIHPSegment).is_empty)
	assert_true((segment_container.get_child(1) as GUIHPSegment).is_empty)
