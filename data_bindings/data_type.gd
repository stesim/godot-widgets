@tool
class_name DataType
extends Resource


func get_default_value() -> Variant:
	return null


func is_same_as(other : DataType) -> bool:
	return other == self


func to_string_name() -> StringName:
	return &""


func _is_same_kind_as(other : DataType) -> bool:
	return other.get_script() == self.get_script()


static func _create_primitive(primitive_type : PrimitiveDataType.PrimitiveType) -> PrimitiveDataType:
	var type := PrimitiveDataType.new()
	type.primitive_type = primitive_type
	return type
