@tool
class_name DataStore
extends Resource


const OVERRIDE_PREFIX := "_override_"


signal data_changed(property : StringName)


var _base : DataStore = null : set = _set_base

var _data := {}

var _data_types := {}



static func from_base(base : DataStore) -> DataStore:
	var store := DataStore.new()
	store._base = base
	return store


func from_property_bindings(bindings : Array[PropertyBinding]) -> void:
	assert(_base == null)

	var data := {}
	var types := {}
	for binding in bindings:
		var property := binding.name
		if binding != null and not property.is_empty():
			types[property] = binding.type
			data[property] = _data.get(property, binding.get_default_value())
	_data = data
	_data_types = types
	_update()


#func _init() -> void:
#	resource_local_to_scene = true


func _get(property : StringName) -> Variant:
	if _base != null and property.begins_with(OVERRIDE_PREFIX):
		var property_name := property.substr(OVERRIDE_PREFIX.length())
		if property_name in _base:
			return _data.has(property_name)

	var value : Variant = _data.get(property, null)
	return _base.get(property) if value == null and _base != null else value


func _set(property : StringName, value : Variant) -> bool:
	if _base != null and property.begins_with(OVERRIDE_PREFIX):
		var property_name := property.substr(OVERRIDE_PREFIX.length())
		if property_name in _base:
			if value == true and not property_name in _data:
				_data[property_name] = _base[property_name]
			elif value == false:
				_data.erase(property_name)
			_update()
			return true

	if property in _data:
		_data[property] = value
		data_changed.emit(property)
		return true

	return false


func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary] = []

	properties.push_back({
		name = "_data",
		type = TYPE_DICTIONARY,
		usage = PROPERTY_USAGE_NO_EDITOR,
	})

	properties.push_back({
		name = "_base",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "DataStore",
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY,
	})

	if _base != null:
		var base_properties := _base._get_property_list()
		for property in base_properties:
			if property.name in _data:
				properties.push_back(property)

		for property in base_properties:
			if not property.name.begins_with("_"):
				properties.push_back({
					name = OVERRIDE_PREFIX + property.name,
					type = TYPE_BOOL,
					usage = PROPERTY_USAGE_EDITOR,
				})
	else:
		for property in _data_types:
			properties.push_back({
				name = property,
				type = _data_types[property],
				usage = PROPERTY_USAGE_EDITOR,
			})

		properties.push_back({
			name = "_data_types",
			type = TYPE_DICTIONARY,
			usage = PROPERTY_USAGE_NO_EDITOR,
		})
	return properties


func _set_base(value : DataStore) -> void:
	if _base == value:
		return
	if _base != null:
		_base.changed.disconnect(_on_base_changed)
		_base.changed.disconnect(_on_base_data_changed)
	_base = value
	if _base != null:
		_base.changed.connect(_on_base_changed)
		_base.changed.connect(_on_base_data_changed)
	_on_base_changed()


func _on_base_changed() -> void:
	for property in _data.keys():
		if not property in _base or typeof(_data[property]) != typeof(_base[property]):
			_data.erase(property)
	_update()


func _on_base_data_changed(property : StringName) -> void:
	if not property in _data:
		data_changed.emit(property)


func _update() -> void:
	notify_property_list_changed()
	emit_changed()

