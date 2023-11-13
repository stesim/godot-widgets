@tool
class_name DataType
extends Resource


enum Base {
	VOID = -1,
	VARIANT = -2,
	BOOL = TYPE_BOOL,
	INT = TYPE_INT,
	FLOAT = TYPE_FLOAT,
	STRING = TYPE_STRING,
	VECTOR2 = TYPE_VECTOR2,
	COLOR = TYPE_COLOR,
	OBJECT = TYPE_OBJECT,
	ARRAY = TYPE_ARRAY,
}


const BASE_TYPE_STRINGS = {
	Base.VOID: &"void",
	Base.VARIANT: &"Variant",
	Base.BOOL: &"bool",
	Base.INT: &"int",
	Base.FLOAT: &"float",
	Base.STRING: &"String",
	Base.VECTOR2: &"Vector2",
	Base.COLOR: &"Color",
	Base.OBJECT: &"Object",
	Base.ARRAY: &"Array",
}


# TODO: make shared types immutable?
static var VOID := create(Base.VOID)
static var VARIANT := create(Base.VARIANT)
static var BOOL := create(Base.BOOL)
static var INT := create(Base.INT)
static var FLOAT := create(Base.FLOAT)
static var STRING := create(Base.STRING)
static var VECTOR2 := create(Base.VECTOR2)
static var COLOR := create(Base.COLOR)
static var OBJECT := create(Base.OBJECT)
static var ARRAY := create(Base.ARRAY)


@export var base := Base.VOID :
	set(value):
		base = value
		_update_resource_name()

@export var specialization : StringName :
	set(value):
		specialization = value
		_update_resource_name()


@warning_ignore("shadowed_variable")
static func create(base_type : Base, specialization := &"") -> DataType:
	var type := DataType.new()
	type.base = base_type
	type.specialization = specialization
	return type


func _update_resource_name() -> void:
	match base:
		Base.OBJECT: resource_name = specialization
		Base.ARRAY: resource_name = "Array" if specialization.is_empty() else "Array[" + specialization + "]"
		_: resource_name = BASE_TYPE_STRINGS[base]
