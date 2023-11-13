@tool
class_name PrimitiveDataType
extends DataType


static var BOOL := create(PrimitiveType.BOOL)
static var INT := create(PrimitiveType.INT)
static var FLOAT := create(PrimitiveType.FLOAT)
static var STRING := create(PrimitiveType.STRING)
static var VECTOR2 := create(PrimitiveType.VECTOR2)
static var COLOR := create(PrimitiveType.COLOR)


enum PrimitiveType {
	NIL = TYPE_NIL,
	BOOL = TYPE_BOOL,
	INT = TYPE_INT,
	FLOAT = TYPE_FLOAT,
	STRING = TYPE_STRING,
	VECTOR2 = TYPE_VECTOR2,
	COLOR = TYPE_COLOR,
}


const PRIMITIVE_TYPE_STRINGS = {
	PrimitiveType.NIL: &"Nil",
	PrimitiveType.BOOL: &"bool",
	PrimitiveType.INT: &"int",
	PrimitiveType.FLOAT: &"float",
	PrimitiveType.STRING: &"String",
	PrimitiveType.VECTOR2: &"Vector2",
	PrimitiveType.COLOR: &"Color",
}


const PRIMITIVE_TYPE_DEFAULTS = {
	PrimitiveType.NIL: null,
	PrimitiveType.BOOL: bool(),
	PrimitiveType.INT: int(),
	PrimitiveType.FLOAT: float(),
	PrimitiveType.STRING: String(),
	PrimitiveType.VECTOR2: Vector2(),
	PrimitiveType.COLOR: Color(),
}


@export var primitive_type := PrimitiveType.NIL :
	set(value):
		if primitive_type != value:
			primitive_type = value
			_update_resource_name()
			emit_changed()


@warning_ignore("shadowed_variable")
static func create(primitive_type : PrimitiveType) -> PrimitiveDataType:
	var type := PrimitiveDataType.new()
	type.primitive_type = primitive_type
	return type


func get_default_value() -> Variant:
	return PRIMITIVE_TYPE_DEFAULTS.get(primitive_type, null)


func is_same_as(other : DataType) -> bool:
	return other == self or (other.is_same_kind_as(self) and other.primitive_type == self.primitive_type)


func to_string_name() -> StringName:
	return PRIMITIVE_TYPE_STRINGS.get(primitive_type, &"")


func _init() -> void:
	_update_resource_name()


func _update_resource_name() -> void:
	resource_name = to_string_name()
