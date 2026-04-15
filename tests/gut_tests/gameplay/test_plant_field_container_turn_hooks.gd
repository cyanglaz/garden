extends GutTest


class FakePlant extends Plant:
	var marker: String
	var events: Array
	var delay_seconds := 0.0

	func _init(p_marker: String, p_events: Array, p_delay_seconds: float = 0.0) -> void:
		marker = p_marker
		events = p_events
		delay_seconds = p_delay_seconds

	func handle_end_turn_hook(_combat_main: CombatMain) -> void:
		events.append("start_%s" % marker)
		if delay_seconds > 0.0:
			await (Engine.get_main_loop() as SceneTree).create_timer(delay_seconds).timeout
		events.append("end_%s" % marker)


func test_trigger_end_turn_hooks_runs_reverse_order() -> void:
	var field_container := PlantFieldContainer.new()
	autofree(field_container)
	var hook_log: Array = []
	field_container.plants = [
		FakePlant.new("p1", hook_log),
		FakePlant.new("p2", hook_log),
		FakePlant.new("p3", hook_log),
	]
	for plant in field_container.plants:
		autofree(plant)

	await field_container.trigger_end_turn_hooks(null)

	assert_eq(
		hook_log,
		["start_p3", "end_p3", "start_p2", "end_p2", "start_p1", "end_p1"]
	)


func test_trigger_end_turn_hooks_awaits_each_plant_serially() -> void:
	var field_container := PlantFieldContainer.new()
	autofree(field_container)
	var hook_log: Array = []
	var p1 := FakePlant.new("p1", hook_log, 0.0)
	var p2 := FakePlant.new("p2", hook_log, 0.03)
	autofree(p1)
	autofree(p2)
	field_container.plants = [p1, p2]

	await field_container.trigger_end_turn_hooks(null)

	assert_eq(hook_log, ["start_p2", "end_p2", "start_p1", "end_p1"])
