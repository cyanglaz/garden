class_name GUIThingDataTooltip
extends GUITooltip

const SECONDARY_TOOLTIP_DELAY := 0.5

@onready var gui_thing_data_description: GUIThingDataDescription = %GUIThingDataDescription

func _update_with_tooltip_request() -> void:
	var thing_data: ThingData = _tooltip_request.data as ThingData
	gui_thing_data_description.update_with_thing_data(thing_data)
	var status_items := _get_status_items_from_description(thing_data)
	if !status_items.is_empty():
		_schedule_secondary_tooltip(status_items)

func _get_status_items_from_description(thing_data: ThingData) -> Array:
	var raw := thing_data.get_raw_description()
	var pairs := DescriptionParser.find_all_reference_pairs(raw)
	var result: Array = []
	var seen_ids: Dictionary = {}
	for pair in pairs:
		if pair[0] != "resource":
			continue
		var raw_id: String = pair[1]
		var resolved_id: String = raw_id
		if raw_id.begins_with("dt_"):
			var key := raw_id.substr(3)
			if !thing_data.data.has(key):
				continue
			resolved_id = thing_data.data[key]
		if seen_ids.has(resolved_id):
			continue
		seen_ids[resolved_id] = true
		var status: ThingData = MainDatabase.field_status_database.get_data_by_id(resolved_id)
		if status == null:
			status = MainDatabase.player_status_database.get_data_by_id(resolved_id)
		if status != null:
			result.append(status)
	return result

func _schedule_secondary_tooltip(status_items: Array) -> void:
	await get_tree().create_timer(SECONDARY_TOOLTIP_DELAY).timeout
	if !is_inside_tree():
		return
	var anchor_node := _tooltip_request.on_control_node
	if anchor_node == null:
		return
	var request := TooltipRequest.new(
		TooltipRequest.TooltipType.SECONDARY_ICON,
		status_items,
		_tooltip_request.id,
		anchor_node,
		_tooltip_request.tooltip_position
	)
	Events.request_display_tooltip.emit(request)
