class_name ObjectsPool

var _pool := {}
var _type_scenes := {}
var _max_per_type := {}

func set_scene_for_type(scene:Resource, type:String, pool_max:int):
	assert(scene != null)
	assert(!type.is_empty())
	assert(pool_max >= 0)
	_type_scenes[type] = scene
	if _max_per_type.has(type):
		_max_per_type[type] = max(pool_max, _max_per_type[type])
	else:
		_max_per_type[type] = pool_max
	_pool[type] = []

func pre_instantiate_all():
	for scene_key in _type_scenes:
		var scene = _type_scenes[scene_key]
		for i in _max_per_type[scene_key]:
			var obj := _get_instance(scene)
			_pool[scene_key].append(obj)

func spawn_instance_for_type(type:String) -> Node:
	if _pool.has(type) && (_pool[type] as Array).size() > 0:
		var object = _pool[type].pop_back() 
		if object == null || !is_instance_valid(object) || object.get_parent() != null:
			# Object is not valid or
			# Object has not been removed from parent yet, create a new instance
			# This delay is due to `recycle` calls deffered on remove from parent
			return _get_instance(_type_scenes[type])
		return object
	else:
		return _get_instance(_type_scenes[type])

func has_pool(type:String) -> bool:
	return _pool.has(type)

func get_pool_size_for_type(type:String) -> int:
	return _pool[type].size()

func clear():
	for key in _pool:
		for object in _pool[key]:
			object.queue_free()
	_pool.clear()
	_type_scenes.clear()
	_max_per_type.clear()

func recycle(object:Node, type:String):
	object.set_process(false)
	if !_pool.has(type) || _pool[type].size() >= _max_per_type[type]:
		object.queue_free.call_deferred()
	else:
		var parent = object.get_parent()
		if parent:
			parent.remove_child.call_deferred(object)
		_pool[type].append(object)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for key in _pool:
			for object in _pool[key]:
				if is_instance_valid(object):
					object.free()
		_pool.clear()
		_type_scenes.clear()
		_max_per_type.clear()

func _get_instance(scene:Resource) -> Node:
	var obj:Node
	if scene is PackedScene:
		obj = scene.instantiate()
	else:
		# For script only object, call `new` directly
		obj = scene.new()
	return obj
