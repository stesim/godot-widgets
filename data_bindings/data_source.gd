@tool
class_name DataSource
extends Resource


enum DataType {
	NONE = -1,
	BOOL = TYPE_BOOL,
	INT = TYPE_INT,
	FLOAT = TYPE_FLOAT,
	STRING = TYPE_STRING,
	VECTOR2 = TYPE_VECTOR2,
	COLOR = TYPE_COLOR,
	RESOURCE = TYPE_OBJECT,
}


func get_data_type() -> DataType:
	return DataType.NONE
