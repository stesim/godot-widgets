@tool
class_name PropertyBinding
extends Resource


enum DataType {
	BOOL = TYPE_BOOL,
	INT = TYPE_INT,
	FLOAT = TYPE_FLOAT,
	STRING = TYPE_STRING,
	VECTOR2 = TYPE_VECTOR2,
	COLOR = TYPE_COLOR,
	RESOURCE = TYPE_OBJECT,
}


@export var name : StringName :
	get:
		return resource_name
	set(value):
		resource_name = value

@export var type := DataType.FLOAT

@export var effect : DataProcessor = null


func get_default_value() -> Variant:
	match type:
		DataType.BOOL: return false
		DataType.INT: return 0
		DataType.FLOAT: return 0.0
		DataType.STRING: return String()
		DataType.VECTOR2: return Vector2()
		DataType.COLOR: return Color()
		DataType.RESOURCE: return null
	assert(false)
	return null
