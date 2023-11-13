@tool
class_name ObjectDataType
extends DataType


static var OBJECT := ObjectDataType.create(&"Object")
static var RESOURCE := ObjectDataType.create(&"Resource")
static var NODE := ObjectDataType.create(&"Node")


@warning_ignore("shadowed_variable")
static func create(global_class : StringName) -> ObjectDataType:
	var type := ObjectDataType.new()
	type.global_class = global_class
	return type


@export var global_class := &"Object" :
	set(value):
		if value.is_empty():
			value = &"Object"
		if global_class != value:
			global_class = value
			_update_resource_name()
			emit_changed()


func get_default_value() -> Variant:
	return null


func is_same_as(other : DataType) -> bool:
	return other == self or other.global_class == self.global_class


func to_string_name() -> StringName:
	return global_class


func inherits(other : DataType) -> bool:
	return ClassDB.is_parent_class(global_class, other.global_class)


func _init() -> void:
	_update_resource_name()


func _update_resource_name() -> void:
	resource_name = to_string_name()

