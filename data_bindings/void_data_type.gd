@tool
class_name VoidDataType
extends DataType


static var VOID := VoidDataType.new()


# NOTE: the method exists for consistency with other data types; otherwise it
#       is quite pointless
static func create() -> VoidDataType:
	return VoidDataType.new()


func get_default_value() -> Variant:
	return null


func is_same_as(other : DataType) -> bool:
	return other == self or other.is_same_kind_as(self)


func to_string_name() -> StringName:
	return &"void"


func _init() -> void:
	resource_name = to_string_name()
