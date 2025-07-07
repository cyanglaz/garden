class_name Util
extends RefCounted

const GUI_BUTTON_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_button_tooltip.tscn")
const GUI_BINGO_BALL_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_bingo_ball_tooltip.tscn")
const GUI_STATUS_EFFECT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_status_effect_tooltip.tscn")
const GUI_SPACE_EFFECT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_space_effect_tooltip.tscn")
const GUI_ENEMY_PREVIEW_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_enemy_preview_tooltip.tscn")
const GUI_ALERT_POPUP_SCENE := preload("res://scenes/GUI/containers/gui_popup_alert.tscn")
const GUI_SETTINGS_SCENE := preload("res://scenes/GUI/containers/gui_settings_menu.tscn")
const GUI_IN_GAME_MENU_SCENE := preload("res://scenes/GUI/containers/gui_in_game_menu.tscn")
const GUI_BALL_SYMBOL_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_bingo_ball_symbol_tooltip.tscn")
const GUI_PLANT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")
const GUI_WEATHER_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_weather_tooltip.tscn")
const GUI_WARNING_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_warning_tooltip.tscn")
const GUI_RICH_TEXT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_rich_text_tooltip.tscn")
const GUI_POWER_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_power_tooltip.tscn")
const GUI_SYMBOL_SCENE := preload("res://scenes/GUI/bingo_main/shared/gui_symbol.tscn")
const BINGO_BALL_ICON_PREFIX := "res://resources/sprites/icons/balls/icon_"
const POWER_ICON_PREFIX := "res://resources/sprites/icons/powers/icon_"
const STATUS_EFFECT_ICON_PREFIX := "res://resources/sprites/icons/status_effect/icon_"
const BALL_TYPE_ICON_PREFIX := "res://resources/sprites/icons/ball_types/icon_"
const SPACE_EFFECT_ICON_PREFIX := "res://resources/sprites/icons/space_effects/icon_"
const BINGO_BALL_SCRIPT_PREFIX := "res://scenes/bingo/ball_scripts/bingo_ball_script_"
const RESOURCE_ICON_PREFIX := "res://resources/sprites/GUI/icons/resources/icon_"
const POWER_SCRIPT_PREFIX := "res://scenes/bingo/power_scripts/power_script_"
const PLANT_ICON_PREFIX := "res://resources/sprites/GUI/icons/plants/icon_"
const TOOL_ICON_PREFIX := "res://resources/sprites/GUI/icons/tool/icon_"
const WEATHER_ICON_PREFIX := "res://resources/sprites/GUI/icons/weathers/icon_"

const ACTION_ICON_WATER := preload("res://resources/sprites/GUI/icons/resources/icon_water.png")
const ACTION_ICON_LIGHT := preload("res://resources/sprites/GUI/icons/resources/icon_light.png")
const ACTION_ICON_PEST := preload("res://resources/sprites/GUI/icons/resources/icon_pest.png")
const ACTION_ICON_FUNGUS := preload("res://resources/sprites/GUI/icons/resources/icon_fungus.png")
const ACTION_ICON_WEATHER_SUNNY := preload("res://resources/sprites/GUI/icons/weathers/icon_sunny.png")
const ACTION_ICON_WEATHER_RAINY := preload("res://resources/sprites/GUI/icons/weathers/icon_rainy.png")

const GAME_ARENA_SIZE :float = 256
const TOOLTIP_OFFSET:float = 2.0
const FLOAT_EQUAL_EPSILON:float = 0.001

const QUALITY_COLOR := {
	1: Constants.COLOR_WHITE,
	2: Constants.COLOR_GREEN3,
	3: Constants.COLOR_BLUE_4,
	4: Constants.COLOR_ORANGE2,
}

static var _weak_settings_menu:WeakRef
static var _weak_in_game_menu:WeakRef

static func show_settings() -> GUISettingsMenu:
	if _weak_settings_menu && _weak_settings_menu.get_ref():
		return null
	var settings := GUI_SETTINGS_SCENE.instantiate()
	_weak_settings_menu = weakref(settings)
	#Singletons.game_session.add_view_to_top_container(settings)
	settings.animate_show()
	settings.dismissed.connect(func(): _weak_settings_menu = null)
	return settings

static func show_in_game_menu() -> GUIInGameMenuContainer:
	if _weak_in_game_menu && _weak_in_game_menu.get_ref():
		return null
	var in_game_menu := GUI_IN_GAME_MENU_SCENE.instantiate()
	_weak_in_game_menu = weakref(in_game_menu)
	#Singletons.game_session.add_view_to_top_container(in_game_menu)
	in_game_menu.animate_show()
	in_game_menu.dismissed.connect(func(): _weak_in_game_menu = null)
	return in_game_menu

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

#static func display_item_tooltip(item_data:ItemData, on_control_node:Control, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIItemTooltip:
	#var item_tooltip:GUIItemTooltip = GUI_ITEM_TOOLTIP_SCENE.instantiate()
	##Singletons.game_session.add_view_to_top_container(item_tooltip)
	#item_tooltip.setup_with_item(item_data)
	#_display_tool_tip.call_deferred(item_tooltip, on_control_node, tooltip_position)
	#return item_tooltip

static func display_power_tooltip(power_data:PowerData, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIPowerTooltip:
	var power_tooltip:GUIPowerTooltip = GUI_POWER_TOOLTIP_SCENE.instantiate()
	Singletons.game_main.add_view_to_top_container(power_tooltip)
	power_tooltip.tooltip_position = tooltip_position
	power_tooltip.bind_with_power_data(power_data)
	_display_tool_tip.call_deferred(power_tooltip, on_control_node, anchor_mouse, tooltip_position)
	return power_tooltip

static func display_ball_tooltip(ball_data:BingoBallData, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIBingoBallTooltip:
	var ball_tooltip:GUIBingoBallTooltip = GUI_BINGO_BALL_TOOLTIP_SCENE.instantiate()
	Singletons.game_main.add_view_to_top_container(ball_tooltip)
	# tooltip position needs to be set before binding data
	ball_tooltip.tooltip_position = tooltip_position
	ball_tooltip.bind_bingo_ball_data(ball_data)
	_display_tool_tip.call_deferred(ball_tooltip, on_control_node, anchor_mouse, tooltip_position)
	return ball_tooltip

static func display_status_effect_tooltip(status_effect_data:StatusEffectData, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIStatusEffectTooltip:
	var status_effect_tooltip:GUIStatusEffectTooltip = GUI_STATUS_EFFECT_TOOLTIP_SCENE.instantiate()
	Singletons.game_main.add_view_to_top_container(status_effect_tooltip)
	status_effect_tooltip.tooltip_position = tooltip_position
	status_effect_tooltip.bind_status_effect_data(status_effect_data)
	_display_tool_tip.call_deferred(status_effect_tooltip, on_control_node, anchor_mouse, tooltip_position)
	return status_effect_tooltip

static func display_space_effect_tooltip(space_effect:SpaceEffect, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUISpaceEffectTooltip:
	var space_effect_tooltip:GUISpaceEffectTooltip = GUI_SPACE_EFFECT_TOOLTIP_SCENE.instantiate()
	Singletons.game_main.add_view_to_top_container(space_effect_tooltip)
	# tooltip position needs to be set before binding data
	space_effect_tooltip.tooltip_position = tooltip_position
	space_effect_tooltip.bind_space_effect(space_effect)
	_display_tool_tip.call_deferred(space_effect_tooltip, on_control_node, anchor_mouse, tooltip_position)
	return space_effect_tooltip

static func display_warning_tooltip(message:String, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIWarningTooltip:
	var warning_tooltip:GUIWarningTooltip = GUI_WARNING_TOOLTIP_SCENE.instantiate()
	Singletons.game_main.add_view_to_top_container(warning_tooltip)
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

static func display_enemy_preview_tooltip(enemy:Enemy, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition =  GUITooltip.TooltipPosition.TOP) -> GUIEnemyPreviewTooltip:
	var enemy_preview_tooltip:GUIEnemyPreviewTooltip = GUI_ENEMY_PREVIEW_TOOLTIP_SCENE.instantiate()
	Singletons.game_main.add_view_to_top_container(enemy_preview_tooltip)
	# tooltip position needs to be set before binding data
	enemy_preview_tooltip.tooltip_position = tooltip_position
	enemy_preview_tooltip.bind_with_enemy(enemy)
	_display_tool_tip.call_deferred(enemy_preview_tooltip, on_control_node, anchor_mouse, tooltip_position)
	return enemy_preview_tooltip

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

static func get_copied_ui_symbol(symbol:GUISymbol) -> GUISymbol:
	var copied_symbol:GUISymbol = GUI_SYMBOL_SCENE.instantiate()
	copied_symbol.texture = symbol.texture.duplicate()
	copied_symbol.size = symbol.size
	copied_symbol.position = symbol.position
	return copied_symbol

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

static func generate_hex_tiles(width:int, height:int) -> Array[int]:
	var result:Array[int] = []
	@warning_ignore("integer_division")
	var half_height := height/2
	#assert(size % 2 == 1) # Only odd number produce perfect hexgon map
	for j:int in range(0, height):
		var min_i:int
		var max_i:int
		if j <= half_height:
			min_i = half_height-j
			max_i = width - 1
		else:
			min_i = 0
			max_i = width - (j - half_height) - 1
		for i in range(min_i, max_i + 1):
			var id = j*100+i
			result.append(id)
	return result

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


static func get_quality_color(quality:int) -> Color:
	return QUALITY_COLOR[quality]

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


static func get_image_path_for_power_id(id:String) -> String:
	return str(POWER_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_script_path_for_power_id(id:String) -> String:
	return str(POWER_SCRIPT_PREFIX, _trim_upgrade_suffix_from_id(id), ".gd")

static func get_image_path_for_ball_id(id:String) -> String:
	return str(BINGO_BALL_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_icon_image_path_for_plant_id(id:String) -> String:
	return str(PLANT_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_icon_image_path_for_tool_id(id:String) -> String:
	return str(TOOL_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_icon_image_path_for_weather_id(id:String) -> String:
	return str(WEATHER_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_script_path_for_ball_id(id:String) -> String:
	return str(BINGO_BALL_SCRIPT_PREFIX, _trim_upgrade_suffix_from_id(id), ".gd")

static func get_image_path_for_status_effect_id(id:String) -> String:
	return str(STATUS_EFFECT_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_image_path_for_space_effect_id(id:String) -> String:
	return str(SPACE_EFFECT_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_image_path_for_ball_type_id(id:String) -> String:
	return str(BALL_TYPE_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_image_path_for_resource_id(id:String) -> String:
	return str(RESOURCE_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_action_icon_with_action_type(action_type:ActionData.ActionType) -> Texture2D:
	var icon:Texture2D
	match action_type:
		ActionData.ActionType.WATER:
			icon = ACTION_ICON_WATER
		ActionData.ActionType.LIGHT:
			icon = ACTION_ICON_LIGHT
		ActionData.ActionType.PEST:
			icon = ACTION_ICON_PEST
		ActionData.ActionType.FUNGUS:
			icon = ACTION_ICON_FUNGUS
		ActionData.ActionType.WEATHER_SUNNY:
			icon = ACTION_ICON_WEATHER_SUNNY
		ActionData.ActionType.WEATHER_RAINY:
			icon = ACTION_ICON_WEATHER_RAINY
		_:
			assert(false, "Invalid action type to get icon for: " + str(action_type))
	return icon

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
		3:
			return Constants.ENEMY_COLOR
		_:
			assert(false, "Invalid rarity: " + str(rarity))
	return Color.WHITE

static func get_color_for_type(type:BingoBallData.Type) -> Color:
	match type:
		BingoBallData.Type.ATTACK:
			return Constants.COLOR_RED
		BingoBallData.Type.SKILL:
			return Constants.COLOR_BLUE_3
		BingoBallData.Type.STATUS:
			return Constants.COLOR_GRAY2
		_:
			assert(false, "Invalid type: " + str(type))
	return Color.WHITE

static func get_bingo_ball_background_region(bingo_ball:BingoBallData, highlighted:bool = false) -> Vector2:
	var x := 0
	var y := 0
	if bingo_ball && bingo_ball.is_plus:
		y = 22
	if highlighted:
		y = 44
	if bingo_ball:
		if bingo_ball.team == BingoBallData.Team.ENEMY:
			x = 88
		match bingo_ball.rarity:
			0:
				x = 22
			1:
				x = 44
			2:
				x = 66
			3:
				assert(bingo_ball.team == BingoBallData.Team.ENEMY)
				x = 88
			_:
				assert(false, "Invalid rarity: " + str(bingo_ball.rarity))
	return Vector2(x, y)

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

static func float_equal(a:float, b:float) -> bool:
	return abs(a - b) < FLOAT_EQUAL_EPSILON

static func get_color_hex(color:Color) -> String:
	return str("#",color.to_html())
