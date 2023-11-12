@tool
class_name GdscriptVariable
extends GdscriptSymbol


@warning_ignore("shadowed_variable")
static func create(name : StringName, type : GdscriptType, initial_value : GdscriptExpression = null) -> GdscriptVariable:
	var statement := GdscriptVariable.new()
	statement.name = name
	statement.type = type
	statement.initial_value = initial_value
	return statement


@export var type : GdscriptType

@export var initial_value : GdscriptExpression


func generate_code() -> String:
	var code := "var " + name
	if type != null:
		code += " : " + type.generate_code()
	if initial_value != null:
		code += " = " if type != null else " := "
		code += initial_value.generate_code()
	code += "\n"
	return code
