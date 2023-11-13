@tool
class_name ArrayDataType
extends DataType


static var ARRAY := ArrayDataType.create(null)


@warning_ignore("shadowed_variable")
static func create(element_type : DataType) -> ArrayDataType:
	var type := ArrayDataType.new()
	type.element_type = element_type
	return type


@export var element_type : DataType :
	set(value):
		if element_type != value:
			var is_equivalent := element_type.is_same_as(value)
			element_type = value
			if not is_equivalent:
				_update_resource_name()
				emit_changed()


func get_default_value() -> Variant:
	# TODO: [] will return Array;
	#          how can an Array[<element_type>] value be created at runtime?
	return []


func is_same_as(other : DataType) -> bool:
	return other == self or other.element_type.is_same_as(self.element_type)


func to_string_name() -> StringName:
	return "Array[" + element_type.to_string_name() + "]" if element_type != null else "Array"


func _init() -> void:
	_update_resource_name()


func _update_resource_name() -> void:
	resource_name = to_string_name()
