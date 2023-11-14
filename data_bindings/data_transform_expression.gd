@tool
class_name DataTransformExpression
extends DataSource


@export var inputs : Array[DataSource] = []

@export var input_names : Array[StringName] = []

@export_multiline var expression : String

@export var type : DataType


var name : StringName :
	get:
		return resource_name
	set(value):
		resource_name = value


func get_data_type() -> DataType:
	return type


func _get_property_list() -> Array[Dictionary]:
	return [
		{
			name = &"name",
			type = TYPE_STRING_NAME,
			usage = PROPERTY_USAGE_EDITOR,
		},
	]
