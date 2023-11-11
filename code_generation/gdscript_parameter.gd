@tool
class_name GdscriptParameter
extends GdscriptSymbol


static func create(name_ : StringName, type_ : GdscriptType, default_value : GdscriptExpression = null) -> GdscriptParameter:
	var statement := GdscriptParameter.new()
	statement.name = name_
	statement.type = type_
	statement.initial_value = default_value
	return statement
