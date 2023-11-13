@tool
class_name DataFieldSource
extends DataSource


@export var field : DataField :
	set(value):
		field = value
		resource_name = "field: " + field.resource_name if field != null else ""


func get_data_type() -> DataType:
	return field.type
