@tool
class_name GdscriptVariable
extends GdscriptSymbol


static func create(name_ : StringName, type_ : GdscriptType, default_value : GdscriptExpression = null) -> GdscriptVariable:
	var statement := GdscriptVariable.new()
	statement.name = name_
	statement.type = type_
	statement.initial_value = default_value
	return statement


func generate_code() -> String:
	var code := "var " + super.generate_code() + "\n"
	return code
