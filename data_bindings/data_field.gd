@tool
class_name DataField
extends Resource


signal type_changed()


@export var type : DataType :
	set(value):
		if type != value:
			var is_equivalent := type != null and type.is_same_as(value)
			if type != null:
				type.changed.disconnect(_on_type_changed)
			type = value
			if type != null:
				type.changed.connect(_on_type_changed)
			if not is_equivalent:
				_on_type_changed()


var name : StringName :
	get:
		return resource_name
	set(value):
		resource_name = value

var default_value : Variant = null


func _on_type_changed() -> void:
	default_value = type.get_default_value() if type != null else null
	notify_property_list_changed()


const _READ_ONLY_USAGE := PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY

func _get_property_list() -> Array[Dictionary]:
	return [
		{
			name = &"name",
			type = TYPE_STRING_NAME,
			usage = PROPERTY_USAGE_EDITOR,
		},
		_create_default_value_property_info(),
	]


func _create_default_value_property_info() -> Dictionary:
	var property := {
		name = &"default_value",
	}
	_add_property_type_info(property, type)
	return property


func _add_property_type_info(property : Dictionary, data_type : DataType) -> void:
	if data_type is PrimitiveDataType:
		property.type = data_type.primitive_type
	elif data_type is ObjectDataType:
		property.type = TYPE_OBJECT
		_add_property_object_type_hints(property, data_type)
	elif data_type is ArrayDataType:
		property.type = TYPE_ARRAY
		_add_property_array_type_hints(property, data_type)
	else:
		property.type = TYPE_NIL


func _add_property_object_type_hints(property : Dictionary, object_type : ObjectDataType) -> void:
	if object_type.inherits(ObjectDataType.RESOURCE):
		property.hint = PROPERTY_HINT_RESOURCE_TYPE
	elif object_type.inherits(ObjectDataType.NODE):
		property.hint = PROPERTY_HINT_NODE_TYPE
	property.hint_string = object_type.global_class


func _add_property_array_type_hints(property : Dictionary, array_type : ArrayDataType) -> void:
	if array_type.element_type == null:
		return

	var dummy_property := {}
	_add_property_type_info(dummy_property, array_type.element_type)

	property.hint = PROPERTY_HINT_ARRAY_TYPE
	property.hint_string = "%d/%d:%s" % [
		dummy_property.type,
		dummy_property.get(&"hint", PROPERTY_HINT_NONE),
		dummy_property.get(&"hint_string", ""),
	]
