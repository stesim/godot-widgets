@tool
class_name WidgetProperty
extends Resource


enum DataType {
	BOOL = TYPE_BOOL,
	INT = TYPE_INT,
	FLOAT = TYPE_FLOAT,
	STRING = TYPE_STRING,
	VECTOR2 = TYPE_VECTOR2,
	COLOR = TYPE_COLOR,
	OBJECT = TYPE_OBJECT,
}


@export var type := DataType.FLOAT :
	set(value):
		if type != value:
			type = value
			if type != DataType.OBJECT:
				object_type = &""
			default_value = _get_default_value(type)
			notify_property_list_changed()

var object_type : StringName

var name : StringName :
	get:
		return resource_name
	set(value):
		resource_name = value

var default_value : Variant = _get_default_value(type)


const _READ_ONLY_USAGE := PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY


func _get_property_list() -> Array[Dictionary]:
	var is_object := type == DataType.OBJECT
	return [
		{
			name = &"object_type",
			type = TYPE_STRING_NAME,
			usage = PROPERTY_USAGE_DEFAULT if is_object else _READ_ONLY_USAGE,
		}, {
			name = &"name",
			type = TYPE_STRING_NAME,
			usage = PROPERTY_USAGE_EDITOR,
		}, {
			name = &"default_value",
			type = type,
			usage = _READ_ONLY_USAGE if is_object else PROPERTY_USAGE_DEFAULT,
		}
	]


func _get_default_value(data_type : DataType) -> Variant:
	match data_type:
		DataType.BOOL: return false
		DataType.INT: return 0
		DataType.FLOAT: return 0.0
		DataType.STRING: return String()
		DataType.VECTOR2: return Vector2()
		DataType.COLOR: return Color()
		DataType.OBJECT: return null
	assert(false)
	return null
