class_name Util
extends RefCounted

enum ReferenceType {
	RESOURCE,
	OTHER,
}


const GUI_ALERT_POPUP_SCENE := preload("res://scenes/GUI/containers/gui_popup_alert.tscn")

const GUI_BUTTON_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_button_tooltip.tscn")
const GUI_PLANT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")
const GUI_WEATHER_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_weather_tooltip.tscn")
const GUI_FIELD_STATUS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_field_status_tooltip.tscn")
const GUI_ACTIONS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_actions_tooltip.tscn")
const GUI_WARNING_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_warning_tooltip.tscn")
const GUI_RICH_TEXT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_rich_text_tooltip.tscn")
const GUI_TOOL_CARD_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_tool_card_tooltip.tscn")

const FIELD_STATUS_SCRIPT_PREFIX := "res://scenes/main_game/field/status/field_status_script_"
const RESOURCE_ICON_PREFIX := "res://resources/sprites/GUI/icons/resources/icon_"
const PLANT_ICON_PREFIX := "res://resources/sprites/GUI/icons/plants/icon_"
const TOOL_ICON_PREFIX := "res://resources/sprites/GUI/icons/tool/icon_"
const WEATHER_ICON_PREFIX := "res://resources/sprites/GUI/icons/weathers/icon_"

const TOOLTIP_OFFSET:float = 2.0
const FLOAT_EQUAL_EPSILON:float = 0.001

static func show_alert(title:String, message:String, close_button_title:String, by_pass_button_title:String) -> GUIPopupAlert:
	var popup := GUI_ALERT_POPUP_SCENE.instantiate()
	#Singletons.game_session.add_view_to_top_container(popup)
	popup.setup(title, message, close_button_title, by_pass_button_title)
	popup.animate_show()
	return popup
	
static func display_button_tooltip(description:String, shortcut:String, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIButtonTooltip:
	var button_tooltip:GUIButtonTooltip = GUI_BUTTON_TOOLTIP_SCENE.instantiate()
	Singletons.game_main.add_view_to_top_container(button_tooltip)
	button_tooltip.setup(description, shortcut)
	_display_tool_tip.call_deferred(button_tooltip, on_control_node, anchor_mouse, tooltip_position)
	return button_tooltip

static func display_warning_tooltip(message:String, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIWarningTooltip:
	var warning_tooltip:GUIWarningTooltip = GUI_WARNING_TOOLTIP_SCENE.instantiate()
	Singletons.main_game.add_control_to_overlay(warning_tooltip)
	warning_tooltip.setup_with_text(message)
	_display_tool_tip.call_deferred(warning_tooltip, on_control_node, anchor_mouse, tooltip_position)
	return warning_tooltip

static func display_rich_text_tooltip(description:String, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIRichTextTooltip:
	var rich_text_tooltip:GUIRichTextTooltip = GUI_RICH_TEXT_TOOLTIP_SCENE.instantiate()
	Singletons.game_main.add_view_to_top_container(rich_text_tooltip)
	# tooltip position needs to be set before binding data	
	rich_text_tooltip.tooltip_position = tooltip_position
	rich_text_tooltip.setup(description)
	_display_tool_tip.call_deferred(rich_text_tooltip, on_control_node, anchor_mouse, tooltip_position)
	return rich_text_tooltip

static func display_plant_tooltip(plant_data:PlantData, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIPlantTooltip:
	var plant_tooltip:GUIPlantTooltip = GUI_PLANT_TOOLTIP_SCENE.instantiate()
	plant_tooltip.hide()
	Singletons.main_game.add_control_to_overlay(plant_tooltip)
	plant_tooltip.tooltip_position = tooltip_position
	plant_tooltip.update_with_plant_data(plant_data)
	_display_tool_tip.call_deferred(plant_tooltip, on_control_node, anchor_mouse, tooltip_position)
	return plant_tooltip

static func display_weather_tooltip(weather_data:WeatherData, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIWeatherTooltip:
	var weather_tooltip:GUIWeatherTooltip = GUI_WEATHER_TOOLTIP_SCENE.instantiate()
	Singletons.main_game.add_control_to_overlay(weather_tooltip)
	weather_tooltip.tooltip_position = tooltip_position
	weather_tooltip.update_with_weather_data(weather_data)
	_display_tool_tip.call_deferred(weather_tooltip, on_control_node, anchor_mouse, tooltip_position)
	return weather_tooltip

static func display_field_status_tooltip(field_status_data:FieldStatusData, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition, world_space:bool) -> GUIFieldStatusTooltip:
	var field_status_tooltip:GUIFieldStatusTooltip = GUI_FIELD_STATUS_TOOLTIP_SCENE.instantiate()
	Singletons.main_game.add_control_to_overlay(field_status_tooltip)
	field_status_tooltip.tooltip_position = tooltip_position
	field_status_tooltip.update_with_field_status_data(field_status_data)
	_display_tool_tip.call_deferred(field_status_tooltip, on_control_node, anchor_mouse, tooltip_position, world_space)
	return field_status_tooltip

static func display_actions_tooltip(action_datas:Array[ActionData], on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition, world_space:bool) -> GUIActionsTooltip:
	var actions_tooltip:GUIActionsTooltip = GUI_ACTIONS_TOOLTIP_SCENE.instantiate()
	Singletons.main_game.add_control_to_overlay(actions_tooltip)
	actions_tooltip.tooltip_position = tooltip_position
	actions_tooltip.update_with_actions(action_datas)
	_display_tool_tip.call_deferred(actions_tooltip, on_control_node, anchor_mouse, tooltip_position, world_space)
	return actions_tooltip

static func display_tool_card_tooltip(tool_data:ToolData, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition, world_space:bool) -> GUIToolCardTooltip:
	var tool_card_tooltip:GUIToolCardTooltip = GUI_TOOL_CARD_TOOLTIP_SCENE.instantiate()
	Singletons.main_game.add_control_to_overlay(tool_card_tooltip)
	tool_card_tooltip.tooltip_position = tooltip_position
	tool_card_tooltip.update_with_tool_data(tool_data)
	_display_tool_tip.call_deferred(tool_card_tooltip, on_control_node, anchor_mouse, tooltip_position, world_space)
	return tool_card_tooltip

static func _display_tool_tip(tooltip:Control, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP, world_space:bool = false) -> void:
	tooltip.show()
	if tooltip is GUITooltip:
		tooltip.anchor_to_mouse = anchor_mouse
		tooltip.sticky = anchor_mouse
		tooltip.show_tooltip()
		tooltip.update_anchors()
	if anchor_mouse && on_control_node:
		tooltip.triggering_global_rect = on_control_node.get_global_rect()
		return
	if !on_control_node:
		return
	var y_offset:float = 0
	var x_offset:float = 0
	match tooltip_position:
		GUITooltip.TooltipPosition.TOP_RIGHT:
			x_offset = on_control_node.size.x + TOOLTIP_OFFSET
			y_offset = - tooltip.size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.TOP:
			x_offset = on_control_node.size.x/2 - tooltip.size.x/2
			y_offset = - tooltip.size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.RIGHT:
			x_offset = on_control_node.size.x + TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.LEFT:
			x_offset = -tooltip.size.x - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.BOTTOM:
			x_offset = on_control_node.size.x/2 - tooltip.size.x/2
			y_offset = on_control_node.size.y + TOOLTIP_OFFSET
	var reference_position := on_control_node.global_position
	if world_space:
		assert(on_control_node)
		reference_position = get_node_ui_position(tooltip, on_control_node)
	tooltip.global_position = reference_position + Vector2(x_offset, y_offset)
	if tooltip is GUITooltip:
		_adjust_tooltip_position(tooltip, on_control_node, tooltip_position, world_space)

static func _adjust_tooltip_position(tooltip:GUITooltip, on_control_node:Control, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP, world_space:bool = false) -> void:
	match tooltip_position:
		GUITooltip.TooltipPosition.TOP_RIGHT:
			pass
		GUITooltip.TooltipPosition.TOP:
			if tooltip.get_screen_position().y < GUITooltip.OFFSCREEN_PADDING:
				_display_tool_tip(tooltip, on_control_node, false, GUITooltip.TooltipPosition.BOTTOM, world_space)
		GUITooltip.TooltipPosition.RIGHT:
			pass
		GUITooltip.TooltipPosition.BOTTOM:
			pass
	tooltip.adjust_positions()

static func save_obj_array(array:Array) -> Array:
	var result_array := []
	for obj:Object in array:
		assert(obj.has_method("save"))
		result_array.append(obj.save())
	return result_array
	
static func save_objc_dictionary(dictionary:Dictionary) -> Dictionary:
	var result_dictionary := {}
	for key in dictionary.keys():
		var obj = dictionary[key]
		assert(obj.has_method("save"))
		result_dictionary[key] = obj.save()
	return result_dictionary

static func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r

static func get_control_global_position(node:CanvasItem, control:Control) -> Vector2:
	var screen_coords := control.get_viewport_transform() * control.global_position
	return node.get_viewport_transform().affine_inverse() * screen_coords

static func get_node_ui_position(control:Control, node:CanvasItem) -> Vector2:
	var world_coords:Vector2 = node.get_viewport_transform() * node.global_position
	return control.get_viewport_transform().affine_inverse() * world_coords

static func get_first_texture_from_sprite(sprite:Sprite2D) -> Texture2D:
	@warning_ignore("integer_division")
	var x := sprite.frame/sprite.hframes
	var y := sprite.frame%sprite.hframes
	var sprite_image := sprite.texture.get_image()
	var texture_size := sprite.texture.get_size()
	@warning_ignore("integer_division")
	var w := texture_size.x/sprite.hframes
	@warning_ignore("integer_division")
	var h := texture_size.y/sprite.vframes
	@warning_ignore("narrowing_conversion")
	var current_sprite_image := sprite_image.get_region(Rect2i(0, 0, w, h))
	var used_rect := current_sprite_image.get_used_rect()
	var sprite_pixels := current_sprite_image.get_region(used_rect)
	return ImageTexture.create_from_image(sprite_pixels)

static func get_current_image_from_sprite(sprite:Sprite2D, used_region_only:bool = true) -> Image:
	@warning_ignore("integer_division")
	var x := sprite.frame/sprite.hframes
	var y := sprite.frame%sprite.hframes
	var sprite_image := sprite.texture.get_image()
	var texture_size := sprite.texture.get_size()
	@warning_ignore("integer_division")
	var w := texture_size.x/sprite.hframes
	@warning_ignore("integer_division")
	var h := texture_size.y/sprite.vframes
	var current_i := sprite.frame%sprite.hframes
	@warning_ignore("integer_division")
	var current_j := sprite.frame/sprite.hframes
	@warning_ignore("narrowing_conversion")
	var current_sprite_image := sprite_image.get_region(Rect2i(current_i * w, current_j * h, w, h))
	if !used_region_only:
		return current_sprite_image
	var used_rect := current_sprite_image.get_used_rect()
	var sprite_pixels := current_sprite_image.get_region(used_rect)
	return sprite_pixels
	
static func remove_all_children(node:Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
static func read_json_from_file(path:String) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())

static func get_quality_text(quality:int) -> String:
	match quality:
		0:
			return "Common"
		1:
			return "Uncommon"
		2:
			return "Rare"
		3:
			return "Epic"
		4:
			return "Lengendary"
	return ""

static func split_with_delimiters(string:String, delimiters:PackedStringArray) -> PackedStringArray:
	var result_queue:PackedStringArray = [string]
	for delimiter in delimiters:
		var temp_queue:PackedStringArray = []
		while !result_queue.is_empty():
			var next_string:String = result_queue[0]
			result_queue.remove_at(0)
			temp_queue.append_array(next_string.split(delimiter))
		result_queue.append_array(temp_queue)
	return result_queue

static func weighted_roll(choices:Array, weights:Array) -> int:
	assert(choices.size() == weights.size())
	var sum_of_weight = 0
	for weight in weights:
		assert(weight is int)
		sum_of_weight += weight
	var rand = randi_range(0, sum_of_weight-1)
	for i in weights.size():
		if rand < weights[i]:
			return i
		rand -= weights[i]
	assert(false, "should never get here");
	return -1

static func get_all_file_paths(path: String, recursive:bool = true) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":  
		if file_name.ends_with(".remap"):
			file_name = file_name.replace(".remap", "")
		var file_path = path + "/" + file_name  
		if recursive && dir.current_is_dir():  
			file_paths += get_all_file_paths(file_path, recursive)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths

static func get_icon_image_path_for_plant_id(id:String) -> String:
	return str(PLANT_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_icon_image_path_for_tool_id(id:String) -> String:
	return str(TOOL_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_icon_image_path_for_weather_id(id:String) -> String:
	return str(WEATHER_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_script_path_for_field_status_id(id:String) -> String:
	return str(FIELD_STATUS_SCRIPT_PREFIX, _trim_upgrade_suffix_from_id(id), ".gd")

static func get_image_path_for_resource_id(id:String) -> String:
	return str(RESOURCE_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_action_id_with_action_type(action_type:ActionData.ActionType) -> String:
	var id := ""
	match action_type:
		ActionData.ActionType.WATER:
			id = "water"
		ActionData.ActionType.LIGHT:
			id = "light"
		ActionData.ActionType.PEST:
			id = "pest"
		ActionData.ActionType.FUNGUS:
			id = "fungus"
		ActionData.ActionType.DRAW_CARD:
			id = "card"
		ActionData.ActionType.WEATHER_SUNNY:
			id = "sunny"
		ActionData.ActionType.WEATHER_RAINY:
			id = "rainy"
		ActionData.ActionType.NONE:
			pass
	return id

static func get_id_for_tool_speical(special:ToolData.Special) -> String:
	var id := ""
	match special:
		ToolData.Special.ALL_FIELDS:
			id = "all_fields"
	return id

static func formate_references(formatted_description:String, data_to_format:Dictionary, highlight_description_keys:Dictionary, additional_highlight_check:Callable, ) -> String:
	var searching_start_index := 0
	while true:
		var start_index := formatted_description.find("{", searching_start_index)
		if start_index == -1:
			break
		var end_index := formatted_description.find("}", start_index)
		if end_index == -1:
			break
		var reference_id := formatted_description.substr(start_index + 1, end_index - start_index - 1)
		var highlight:bool = additional_highlight_check.call(reference_id)
		var formatted_string := _format_reference(reference_id, data_to_format, highlight_description_keys, highlight)
		formatted_description = formatted_description.substr(0, start_index) + formatted_string + formatted_description.substr(end_index + 1)
		searching_start_index = start_index + formatted_string.length()
	return formatted_description

static func _format_reference(reference_id:String, data_to_format:Dictionary, highlight_description_keys:Dictionary, highlight:bool) -> String:
	# Find the referenced id under the umbrella id
	var parsed_string := ""
	var highlight_color := Constants.COLOR_WHITE
	if (highlight_description_keys.has(reference_id) && highlight_description_keys[reference_id] == true) || highlight:
		highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	if reference_id.begins_with("icon_"):
		parsed_string = _format_icon_reference(reference_id, highlight)
	elif data_to_format.has(reference_id):
		parsed_string = data_to_format[reference_id]
		parsed_string = Util.convert_to_bbc_highlight_text(parsed_string, highlight_color)
	elif reference_id.begins_with("bordered_text:"):
		reference_id = reference_id.trim_prefix("bordered_text:")
		parsed_string = Util.convert_to_bbc_highlight_text(parsed_string, highlight_color)
	return parsed_string

static func _get_level_suffix(reference_id:String) -> String:
	var plus_sign_index := reference_id.find("+")
	if plus_sign_index == -1:
		return ""
	return reference_id.substr(plus_sign_index)

static func _format_icon_reference(reference_id:String, highlight:bool) -> String:
	reference_id = reference_id.trim_prefix("icon_")
	var icon_string := ""
	var image_path : = ""
	var reference_type:ReferenceType = ReferenceType.OTHER

	# For each reference id, create an icon tag, append to the final string with , separated
	if reference_id.begins_with("resource_"):
		reference_type = ReferenceType.RESOURCE
	
	var url_prefix := ""
	var url := ""
	var level_suffix := _get_level_suffix(reference_id)
	match reference_type:
		ReferenceType.RESOURCE:
			reference_id = reference_id.trim_prefix("resource_")
			image_path = Util.get_image_path_for_resource_id(reference_id)
			url = reference_id
	var highlight_color := Constants.COLOR_WHITE
	if highlight:
		highlight_color = Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	icon_string = str("[img=6x6]", image_path, "[/img]") + Util.convert_to_bbc_highlight_text(level_suffix, highlight_color)
	if !url.is_empty():
		icon_string = str("[url=", url_prefix, reference_id, "]", icon_string, "[/url]")
	return icon_string

static func _highlight_string(string:String) -> String:
	# Check if the string is already highlighted
	var highlight_color := Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	if string.begins_with(str("[outline_size=1][color=", Util.get_color_hex(highlight_color), "]")) && string.ends_with("[/color][/outline_size]"):
		return string
	# Check if the string is already highlighted with white
	if string.begins_with(str("[outline_size=1][color=", Util.get_color_hex(Constants.COLOR_WHITE), "]")) && string.ends_with("[/color][/outline_size]"):
		string = string.trim_prefix(str("[outline_size=1][color=", Util.get_color_hex(Constants.COLOR_WHITE), "]"))
		string = string.trim_suffix("[/color][/outline_size]")
		return Util.convert_to_bbc_highlight_text(string, highlight_color)
	assert(!string.begins_with(str("[outline_size=1]")))
	return Util.convert_to_bbc_highlight_text(string, highlight_color)

static func _trim_upgrade_suffix_from_id(id:String) -> String:
	var plus_sign_index := id.find("+")
	if plus_sign_index == -1:
		return id
	id = id.substr(0, plus_sign_index)
	return id

static func get_mutual_items_in_arrays(array1:Array, array2:Array) -> Array:
	var result := []
	for i in array1:
		if i in array2:
			result.append(i)
	return result

static func unweighted_roll(array:Array, count:int = 1) -> Array:
	assert(count > 0 && count <= array.size())
	if count == 1:
		return [array.pick_random()]
	var index_array := []
	for i in array.size():
		index_array.append(i)
	index_array.shuffle()
	var result := []
	for i in count:
		result.append(array[index_array.pop_back()])
	return result

static func array_find(array:Array, callable:Callable) -> int:
	var index := 0
	for item in array:
		if callable.call(item):
			return index
		index += 1
	return -1

static func get_color_for_rarity(rarity:int) -> Color:
	match rarity:
		0:
			return Constants.COMMON_C0LOR
		1:
			return Constants.UNCOMMON_COLOR
		2:
			return Constants.RARE_COLOR
		_:
			assert(false, "Invalid rarity: " + str(rarity))
	return Color.WHITE

static func get_plant_icon_background_region(plant_data:PlantData, highlighted:bool = false) -> Vector2:
	var x := 0
	var y := 0
	if highlighted:
		y = 16
	if plant_data:
		match plant_data.rarity:
			0:
				x = 0
			1:
				x = 16
			2:
				x = 32
			3:
				x = 48
			_:
				assert(false, "Invalid rarity: " + str(plant_data.rarity))
	return Vector2(x, y)

static func get_tool_icon_background_region(_tool_data:ToolData, highlighted:bool = false) -> Vector2:
	var x := 0
	var y := 0
	if highlighted:
		y = 16
	return Vector2(x, y)

static func create_scaled_tween(binding_node:Node) -> Tween:
	var tween:Tween = binding_node.create_tween()
	tween.set_speed_scale(_get_game_speed_scale())
	return tween

static func create_scaled_timer(duration:float) -> SceneTreeTimer:
	var scale := _get_game_speed_scale()
	var timer:SceneTreeTimer = Singletons.main_game.get_tree().create_timer(duration * (1/scale))
	return timer

# Unnoticiable timer, usually used to make async methods always async.
static func await_for_tiny_time() -> void:
	await Util.create_scaled_timer(0.05).timeout

# Noticiable timer, usually used to make pauses between animation sequences.
static func await_for_small_time() -> void:
	await Util.create_scaled_timer(0.15).timeout

static func remove_duplicates_from_array(array:Array) -> Array:
	var result:Array = []
	for item in array:
		if item not in result:
			result.append(item)
	return result

static func _get_game_speed_scale() -> float:
	match PlayerSettings.setting_data.game_speed:
		0:
			return 1.0
		1:
			return 1.2
		2:
			return 1.4
	return 1

static func convert_to_bbc_highlight_text(string:String, color:Color) -> String:
	return str("[outline_size=1][color=", Util.get_color_hex(color), "]", string, "[/color][/outline_size]")

static func get_localized_string(localized_key:String) -> String:
	var string := Singletons.tr(localized_key)
	if string.begins_with(" "):
		string = string.substr(1)
	return string

static func float_equal(a:float, b:float) -> bool:
	return abs(a - b) < FLOAT_EQUAL_EPSILON

static func get_color_hex(color:Color) -> String:
	return str("#",color.to_html())
