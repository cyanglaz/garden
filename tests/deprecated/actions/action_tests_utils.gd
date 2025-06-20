class_name ActionTestsUtils
	
static func test_directional_indicator(guttest:GutTest, action:Action, action_emitter:ActionEmitter, room:Room) -> void:
	var indicator:DirectionalActionIndicator
	for ind in action_emitter.action_indicator_container.get_children():
		if ind is DirectionalActionIndicator:
			indicator = ind
			break
	var from_global_position := room.get_tile_position(action.emitting_from_position_id)
	var to_global_position := room.get_tile_position(action.target_tile_id)
	var angle := from_global_position.direction_to(to_global_position).angle()
	var from_point_position = from_global_position + DirectionalActionIndicator.OFFSET.rotated(angle)
	var to_point_position = to_global_position - DirectionalActionIndicator.OFFSET.rotated(angle)
	var total_distance := from_point_position.distance_to(to_point_position)
	var steps := Arena.get_distance(action.emitting_from_position_id, action.target_tile_id) * 2
	var dot_distance := total_distance / steps
	for i:int in steps + 1:
		var dot:ActionIndicatorDots = indicator._dot_container.get_child(i)
		var dot_position :Vector2= from_point_position + i * dot_distance * Vector2.RIGHT.rotated(angle)
		guttest.assert_almost_eq(dot.global_position, dot_position, Vector2(0.01, 0.01))	
		
static func test_push_indicator(guttest:GutTest, action:Action, action_emitter:ActionEmitter, room:Room) -> void:
	var indicator:CharacterPushIndicator 
	for ind in action_emitter.action_indicator_container.get_children():
		if ind is CharacterPushIndicator:
			indicator = ind
			break
			
	var line := indicator.line_2d
	var from_point_position := line.get_point_position(0)
	var to_point_position := line.get_point_position(1)
	
	var from_global_position := room.get_tile_position(action.target_tile_id)
	var to_global_position := room.get_tile_position((action.action_handle as PushHandle).landing_tile_id)
	var angle := from_global_position.direction_to(to_global_position).angle()

	var actual_from = from_point_position + line.global_position
	var expected_from = action_emitter.room.get_tile_position(action.target_tile_id) + CharacterPushIndicator.OFFSET.rotated(angle)
	var actual_to = to_point_position + line.global_position
	var expected_to = action_emitter.room.get_tile_position((action.action_handle as PushHandle).landing_tile_id) - CharacterPushIndicator.OFFSET.rotated(angle)
	
	guttest.assert_almost_eq(actual_from, expected_from, Vector2(0.01, 0.01))
	guttest.assert_almost_eq(actual_to, expected_to, Vector2(0.01, 0.01))

static func test_action_target_indicator(guttest:GutTest, action:Action, action_emitter:ActionEmitter) -> void:
	var indicator:ActionTargetTileIndicator
	for ind in action_emitter.action_indicator_container.get_children():
		if ind is ActionTargetTileIndicator:
			indicator = ind
			break
	guttest.assert_true(indicator.global_position == action.room.get_tile_position(action.target_tile_id))
	if action.action_handle is AttackHandle:
		guttest.assert_eq(indicator._damage_label.text, str(action.action_handle.damage))
	match action_emitter.indicator_state:
		CombatIndicator.IndicatorState.NORMAL:
			guttest.assert_false(indicator._damage_label.visible)	
			guttest.assert_true(indicator._sprite_2d.visible)
		CombatIndicator.IndicatorState.HIGHLIGHTED:
			guttest.assert_true(indicator._damage_label.visible)
			guttest.assert_true(indicator._sprite_2d.visible)

static func test_artillery_action_indicator(guttest:GutTest, action:Action, action_emitter:ActionEmitter) -> void:
	var indicator:ArtilleryActionIndicator
	for ind in action_emitter.action_indicator_container.get_children():
		if ind is ArtilleryActionIndicator:
			indicator = ind
			break
	var steps := indicator._calculate_steps(action.emitting_from_position_id, action.target_tile_id, action.room)
	var from_global_position := indicator._get_from_tile_position(action.emitting_from_position_id, action.room)
	var to_global_position := indicator._get_to_tile_position(action.target_tile_id, action.room)
	var curve := Util.calculate_artillery_path(from_global_position, to_global_position, steps)
	for i in steps:
		var dot:ActionIndicatorDots = indicator._dot_container.get_child(i)
		guttest.assert_almost_eq(dot.global_position, curve[i], Vector2(0.01, 0.01))	
