class_name Serializer

const NOISE_KEYS := ["script", "Script", "res"]

static func json_to_class(json: Dictionary, _class: Object) -> Object:
	var properties: Array = _class.get_property_list()
	for key in json.keys():
		for property in properties:
			if property.name == key:
				if (property["class_name"] in ["Reference", "Object"] and property["type"] == 17):
					_class.set(key, json_to_class(json[key], _class.get(key)))
				elif property.type == Variant.Type.TYPE_DICTIONARY:
					_restore_dictionary(property.name, json, _class)
				else:
					_class.set(key, json[key])
				break
			# Below lines are to add descriptions of the class, they will be useful when we want to reinitialize the objects
			#if key == property.hint_string:
				#if (property["class_name"] in ["Reference", "Object"] and property["type"] == 17):
					#_class.set(property.name, json_to_class(json[key], _class.get(key)))
				#else:
					#_class.set(property.name, json[key])
				#break
	return _class

static func class_to_json(_class: Object) -> Dictionary:
	if _class == null:
		return {}
	var result: Dictionary = {}
	var properties: Array = _class.get_property_list()
	for property in properties:
		if property.name in NOISE_KEYS:
			continue
		if property["name"].is_empty():		
			continue		
		if property["class_name"] in ["Reference", "Object"]  && property.type == 24:
			result[property.name] = class_to_json(_class.get(property.name))
		elif property.type == Variant.Type.TYPE_DICTIONARY:
			var child_dictionary:Dictionary = _class.get(property.name)
			result[property.name] = _parse_dictionary(child_dictionary)
		elif property.type == Variant.Type.TYPE_ARRAY:
			var child_array:Array = _class.get(property.name)
			result[property.name] = _parse_array(child_array)
		else:
			result[property.name] = _class.get(property.name)
		# Below lines are to add descriptions of the class, they will be useful when we want to reinitialize the objects
		#if not property["hint_string"].is_empty():
			#if property["class_name"] in ["Reference", "Object"]:
				#result[property.hint_string] = class_to_json(_class.get(property.name))
			#else:
				#result[property.hint_string] = _class.get(property.name)
	return result

static func _parse_dictionary(property_dictionary:Dictionary) -> Dictionary:
	var result_dictionary:Dictionary
	for key in property_dictionary:
		var value = property_dictionary[key]
		var parsed_value:Variant = _parse_value(value)
		result_dictionary[key] = parsed_value
	return result_dictionary
	
static func _parse_array(property_array:Array) -> Array:
	var result_array:Array = []
	for value in property_array:
		var parsed_value:Variant = _parse_value(value)
		result_array.append(parsed_value)
	return result_array

static func _parse_value(value:Variant) -> Variant:
	if value is Object:
		return class_to_json(value)
	elif value is Dictionary:
		return _parse_dictionary(value)
	elif value is Array:
		return _parse_array(value)
	else:
		return value

static func _restore_dictionary(key:String, json:Dictionary, _class:Object) -> void:
	var dictionary:Dictionary = json[key]
	var class_object = _class.get(key)
	assert(class_object is Dictionary, "snapshot should be dictionary")
	if dictionary.is_empty():
		_class.set(key, {})
	elif dictionary.values()[0] is Dictionary:
		for dictionary_key in class_object:
			if dictionary[dictionary_key] == null:
				class_object[dictionary_key] = null
			else:
				json_to_class(dictionary[dictionary_key], class_object[dictionary_key])
	else:
		_class.set(key, dictionary)
