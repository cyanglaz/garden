class_name Util
extends RefCounted

const GUI_ALERT_POPUP_SCENE := preload("res://scenes/GUI/containers/gui_popup_alert.tscn")

const FIELD_STATUS_SCRIPT_PREFIX := "res://scenes/main_game/combat/fields/status/field_status_script_"
const POWER_SCRIPT_PREFIX := "res://scenes/main_game/power/power_scripts/power_script_"
const RESOURCE_ICON_PREFIX := "res://resources/sprites/GUI/icons/resources/icon_"
const SIGN_ICON_PREFIX := "res://resources/sprites/GUI/icons/cards/signs/icon_"
const VALUE_ICON_PREFIX := "res://resources/sprites/GUI/icons/cards/values/icon_"
const PLANT_ICON_PREFIX := "res://resources/sprites/GUI/icons/plants/icon_"
const TOOL_ICON_PREFIX := "res://resources/sprites/GUI/icons/tool/icon_"
const WEATHER_ICON_PREFIX := "res://resources/sprites/GUI/icons/weathers/icon_"

const TOOLTIP_OFFSET:float = 2.0
const FLOAT_EQUAL_EPSILON:float = 0.001
const ERROR_SHAKE_OFFSET := 1.0

static func get_uuid() -> String:
	return str(Time.get_unix_time_from_system()) + "_" + str(randi_range(0, 1000000)) + "_" + str(Time.get_ticks_msec())

static func show_alert(title:String, message:String, close_button_title:String, by_pass_button_title:String) -> GUIPopupAlert:
	var popup := GUI_ALERT_POPUP_SCENE.instantiate()
	#Singletons.game_session.add_view_to_top_container(popup)
	popup.setup(title, message, close_button_title, by_pass_button_title)
	popup.animate_show()
	return popup

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

static func get_node_canvas_position(node:CanvasItem) -> Vector2:
	return node.get_global_transform_with_canvas().origin

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

static func is_collision_layer_bit_set(collision_layer:int, bit:int) -> bool:
	return collision_layer & bit == bit
	
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

static func weighted_roll(choices:Array, weights:Array) -> Variant:
	assert(choices.size() == weights.size())
	var sum_of_weight = 0
	for weight in weights:
		assert(weight is int)
		sum_of_weight += weight
	var rand = randi_range(0, sum_of_weight-1)
	for i in weights.size():
		if rand < weights[i]:
			return choices[i]
		rand -= weights[i]
	assert(false, "should never get here");
	return null

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

static func get_script_path_for_power_id(id:String) -> String:
	return str(POWER_SCRIPT_PREFIX, _trim_upgrade_suffix_from_id(id), ".gd")

static func get_image_path_for_resource_id(id:String) -> String:
	return str(RESOURCE_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_image_path_for_sign_id(id:String) -> String:
	return str(SIGN_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func get_image_path_for_value_id(id:String) -> String:
	return str(VALUE_ICON_PREFIX, _trim_upgrade_suffix_from_id(id), ".png")

static func _trim_upgrade_suffix_from_id(id:String) -> String:
	var plus_sign_index := id.find("+")
	if plus_sign_index == -1:
		return id
	id = id.substr(0, plus_sign_index)
	return id

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
		ActionData.ActionType.RECYCLE:
			id = "recycle"
		ActionData.ActionType.DRAW_CARD:
			id = "draw_card"
		ActionData.ActionType.DISCARD_CARD:
			id = "discard_card"
		ActionData.ActionType.WEATHER_SUNNY:
			id = "sunny"
		ActionData.ActionType.WEATHER_RAINY:
			id = "rainy"
		ActionData.ActionType.GREENHOUSE:
			id = "greenhouse"
		ActionData.ActionType.DEW:
			id = "dew"
		ActionData.ActionType.ENERGY:
			id = "energy"
		ActionData.ActionType.UPDATE_X:
			id = "update_x"
		ActionData.ActionType.UPDATE_GOLD:
			id = "gain_gold"
		ActionData.ActionType.UPDATE_HP:
			id = "update_hp"
		ActionData.ActionType.UPDATE_MOVEMENT:
			id = "update_movement"
		ActionData.ActionType.NONE:
			pass
	return id

static func get_action_type_from_action_id(action_id:String) -> ActionData.ActionType:
	match action_id:
		"light":
			return ActionData.ActionType.LIGHT
		"water":
			return ActionData.ActionType.WATER
		"pest":
			return ActionData.ActionType.PEST
		"fungus":
			return ActionData.ActionType.FUNGUS
		"recycle":
			return ActionData.ActionType.RECYCLE
		"sunny":
			return ActionData.ActionType.WEATHER_SUNNY
		"rainy":
			return ActionData.ActionType.WEATHER_RAINY
		"draw_card":
			return ActionData.ActionType.DRAW_CARD
		"discard_card":
			return ActionData.ActionType.DISCARD_CARD
		"greenhouse":
			return ActionData.ActionType.GREENHOUSE
		"dew":
			return ActionData.ActionType.DEW
		"energy":
			return ActionData.ActionType.ENERGY
		"update_x":
			return ActionData.ActionType.UPDATE_X
		"gain_gold":
			return ActionData.ActionType.UPDATE_GOLD
		"update_hp":
			return ActionData.ActionType.UPDATE_HP
		"update_movement":
			return ActionData.ActionType.UPDATE_MOVEMENT
		"none":
			return ActionData.ActionType.NONE
	assert(false, "Invalid action id: " + action_id)
	return ActionData.ActionType.NONE

static func get_action_name_from_action_type(action_type:ActionData.ActionType) -> String:
	var action_name := ""
	match action_type:
		ActionData.ActionType.LIGHT:
			action_name = Util.get_localized_string("ACTION_NAME_LIGHT")
		ActionData.ActionType.WATER:
			action_name = Util.get_localized_string("ACTION_NAME_WATER")
		ActionData.ActionType.PEST:
			action_name = Util.get_localized_string("ACTION_NAME_PEST")
		ActionData.ActionType.FUNGUS:
			action_name = Util.get_localized_string("ACTION_NAME_FUNGUS")
		ActionData.ActionType.WEATHER_SUNNY:
			action_name = Util.get_localized_string("ACTION_NAME_WEATHER_SUNNY")
		ActionData.ActionType.WEATHER_RAINY:
			action_name = Util.get_localized_string("ACTION_NAME_WEATHER_RAINY")
		ActionData.ActionType.DRAW_CARD:
			action_name = Util.get_localized_string("ACTION_NAME_DRAW_CARD")
		ActionData.ActionType.DISCARD_CARD:
			action_name = Util.get_localized_string("ACTION_NAME_DISCARD_CARD")
		ActionData.ActionType.RECYCLE:
			action_name = Util.get_localized_string("ACTION_NAME_RECYCLE")
		ActionData.ActionType.GREENHOUSE:
			action_name = Util.get_localized_string("ACTION_NAME_GREENHOUSE")
		ActionData.ActionType.DEW:
			action_name = Util.get_localized_string("ACTION_NAME_DEW")
		ActionData.ActionType.ENERGY:
			action_name = Util.get_localized_string("ACTION_NAME_ENERGY")
		ActionData.ActionType.UPDATE_X:
			action_name = Util.get_localized_string("ACTION_NAME_UPDATE_X")
		ActionData.ActionType.UPDATE_GOLD:
			action_name = Util.get_localized_string("ACTION_NAME_UPDATE_GOLD")
		ActionData.ActionType.UPDATE_HP:
			action_name = Util.get_localized_string("ACTION_NAME_UPDATE_HP")
		ActionData.ActionType.UPDATE_MOVEMENT:
			action_name = Util.get_localized_string("ACTION_NAME_UPDATE_MOVEMENT")
		ActionData.ActionType.NONE:
			pass
	return action_name

static func get_id_for_tool_speical(special:ToolData.Special) -> String:
	var id := ""
	match special:
		ToolData.Special.COMPOST:
			id = "compost"
		ToolData.Special.WITHER:
			id = "wither"
		ToolData.Special.NIGHTFALL:
			id = "nightfall"
		ToolData.Special.FLIP_FRONT:
			id = "flip_front"
		ToolData.Special.FLIP_BACK:
			id = "flip_back"
		_:
			assert(false, "special id not implemented")
	return id

static func get_special_from_id(id:String) -> ToolData.Special:
	match id:
		"compost":
			return ToolData.Special.COMPOST
		"wither":
			return ToolData.Special.WITHER
		"nightfall":
			return ToolData.Special.NIGHTFALL
		"flip_front":
			return ToolData.Special.FLIP_FRONT
		"flip_back":
			return ToolData.Special.FLIP_BACK
		_:
			assert(false, "Invalid special id: %s" % id)
	return ToolData.Special.COMPOST

static func get_id_for_action_speical(special:ActionData.Special) -> String:
	var id := ""
	match special:
		ActionData.Special.ALL_FIELDS:
			id = "all_fields"
	return id

static func get_id_for_attack_type(attack_type:AttackData.AttackType) -> String:
	var id := ""
	match attack_type:
		AttackData.AttackType.SIMPLE:
			id = "simple"
		_:
			assert(false, str("unrecognized attack type, ", attack_type))
	return id

static func find_tool_ids_in_data(data:Dictionary) -> Array[String]:
	var tool_ids:Array[String] = []
	for key:String in data.keys():
		if key.begins_with("card_"):
			var key_parts:Array = key.split("_")
			var tool_id:String = key_parts[1]
			tool_ids.append(tool_id)
	return tool_ids


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

static func get_color_for_card_rarity(rarity:int) -> Color:
	return Constants.CARD_RARITY_COLOR[rarity]

static func get_plant_icon_background_region(plant_data:PlantData, highlighted:bool = false) -> Vector2:
	var x := 0
	var y := 0
	if highlighted:
		y = 16
	if plant_data:
		match plant_data.difficulty:
			0:
				x = 0
			1:
				x = 18
			2:
				x = 36
			3:
				x = 54
			_:
				assert(false, "Invalid difficulty: " + str(plant_data.difficulty))
	return Vector2(x, y)

static func get_plant_name_color(plant_data:PlantData) -> Color:
	match plant_data.difficulty:
		0:
			return Constants.COLOR_GREEN3
		1:
			return Constants.COLOR_BLUE_3
		2:
			return Constants.COLOR_RED1
		_:
			assert(false, "Invalid difficulty: " + str(plant_data.difficulty))
	return Constants.COLOR_WHITE

static func create_scaled_tween(binding_node:Node) -> Tween:
	var tween:Tween = binding_node.create_tween()
	tween.set_speed_scale(_get_game_speed_scale())
	return tween

static func create_scaled_timer(duration:float) -> SceneTreeTimer:
	var scale := _get_game_speed_scale()
	var timer:SceneTreeTimer = Singletons.get_tree().create_timer(duration * (1/scale))
	return timer

# Unnoticiable timer, usually used to make async methods always async.
static func await_for_tiny_time() -> void:
	await Util.create_scaled_timer(0.005).timeout

# Noticiable timer, usually used to make pauses between animation sequences.
static func await_for_small_time() -> void:
	await Util.create_scaled_timer(0.15).timeout

static func remove_duplicates_from_array(array:Array) -> Array:
	var result:Array = []
	for item in array:
		if item not in result:
			result.append(item)
	return result

static func play_error_shake_animation(object:Object, position_property:String, original_position:Vector2, duration:float = 0.1) -> void:
	var tween:Tween = Util.create_scaled_tween(object)
	tween.tween_property(object, position_property, original_position + Vector2.LEFT * ERROR_SHAKE_OFFSET, duration/4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(object, position_property, original_position + Vector2.RIGHT * ERROR_SHAKE_OFFSET, duration/4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(object, position_property, original_position + Vector2.LEFT * ERROR_SHAKE_OFFSET, duration/4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(object, position_property, original_position, duration/4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

static func _get_game_speed_scale() -> float:
	match PlayerSettings.setting_data.game_speed:
		0:
			return 1.0
		1:
			return 1.2
		2:
			return 1.4
	return 1

static func convert_to_bbc_highlight_text(string:String, color:Color, outline_size:int = 1, outline_color:Color = Constants.COLOR_BLACK) -> String:
	var final_string := string
	if color:
		final_string = "[color=%s]%s[/color]" % [Util.get_color_hex(color), string]
	if outline_size > 0:
		final_string = "[outline_size=%s]%s[/outline_size]" % [str(outline_size), final_string]
	final_string = "[outline_color=%s]%s[/outline_color]" % [Util.get_color_hex(outline_color), final_string]
	return final_string

static func get_localized_string(localized_key:String) -> String:
	var string := Singletons.tr(localized_key)
	if string.begins_with(" "):
		string = string.substr(1)
	return string

static func float_equal(a:float, b:float) -> bool:
	return abs(a - b) < FLOAT_EQUAL_EPSILON

static func get_color_hex(color:Color) -> String:
	return str("#",color.to_html())
