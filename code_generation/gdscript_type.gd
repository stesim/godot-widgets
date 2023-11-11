@tool
class_name GdscriptType
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


@export var base := Base.VARIANT

@export var specific : StringName


static func create(base_type : Base, specialization := "") -> GdscriptType:
	var type := GdscriptType.new()
	type.base = base_type
	type.specific = specialization
	return type


func generate_code() -> String:
	match base:
		Base.OBJECT:
			return BASE_TYPE_STRINGS[Base.OBJECT] if specific.is_empty() else specific
		Base.ARRAY:
			var string := String(BASE_TYPE_STRINGS[Base.ARRAY])
			return string if specific.is_empty() else string + "[" + specific + "]"
		_:
			return BASE_TYPE_STRINGS[base]


func specialize(subtype : String) -> GdscriptType:
	assert(specific.is_empty())
	var specialized := duplicate()
	specialized.specific = subtype
	return specialized
