@tool
class_name DataField
extends Resource


@export var type : DataType


var name : StringName :
	get:
		return resource_name
	set(value):
		resource_name = value


func _get_property_list() -> Array[Dictionary]:
	return [
		{
			name = &"name",
			type = TYPE_STRING_NAME,
			usage = PROPERTY_USAGE_EDITOR,
		}
	]

