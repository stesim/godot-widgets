@tool
class_name GdscriptParameter
extends GdscriptVariable


@warning_ignore("shadowed_variable")
static func create_parameter(name : StringName, type : GdscriptType, default_value : GdscriptExpression = null) -> GdscriptParameter:
	var statement := GdscriptParameter.new()
	statement.name = name
	statement.type = type
	statement.initial_value = default_value
	return statement


func generate_code() -> String:
	var code := name
	if type != null:
		code += " : " + type.generate_code()
	if initial_value != null:
		code += " = " if type != null else " := "
		code += initial_value.generate_code()
	return code
