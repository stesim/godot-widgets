@tool
class_name Widget
extends Node3D


var property_bindings : Array[PropertyBinding] = [] :
	set(value):
		property_bindings = value
		_bindings_by_name.clear()
		for binding in property_bindings:
			if binding != null and not binding.name.is_empty():
				_bindings_by_name[binding.name] = binding

		for property in _state.keys():
			if not property in _bindings_by_name:
				_state.erase(property)
		for property in _bindings_by_name:
			if not property in _state:
				_state[property] = _bindings_by_name[property].get_default_value()


var _bindings_by_name := {}

var _state := {}


func _ready() -> void:
	for property in _bindings_by_name:
		_on_state_data_changed(property)


func _on_state_data_changed(property : StringName) -> void:
	if not is_inside_tree():
		return
	var binding : PropertyBinding = _bindings_by_name.get(property)
	if binding == null:
		push_error("no property binding for state property: ", property)
	elif binding.effect != null:
		binding.effect.process(self, _state[property])


func _get(property : StringName) -> Variant:
	if property in _bindings_by_name:
		var value : Variant = _state.get(property)
		return value
	return null


func _set(property : StringName, value : Variant) -> bool:
	if property in _bindings_by_name:
		_state[property] = value
		_on_state_data_changed(property)
	return false


func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary] = []

	var is_currently_edited := (
		Engine.is_editor_hint()
		and is_inside_tree()
		and (owner == null or (scene_file_path.is_empty() and owner == get_tree().edited_scene_root))
	)
	properties.push_back({
		name = &"property_bindings",
		type = TYPE_ARRAY,
		hint = PROPERTY_HINT_ARRAY_TYPE,
		hint_string = "%d/%d:%s" % [TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE, "PropertyBinding"],
		usage = PROPERTY_USAGE_DEFAULT if is_currently_edited else PROPERTY_USAGE_NO_EDITOR,
	})

	for binding in property_bindings:
		properties.push_back({
			name = binding.name,
			type = binding.type,
		})
	return properties
