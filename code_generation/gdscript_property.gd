@tool
class_name GdscriptProperty
extends GdscriptSymbol


@export var setter : GdscriptFunction = null


@warning_ignore("shadowed_variable")
static func create(name : StringName, type : GdscriptType, default_value : GdscriptExpression = null) -> GdscriptProperty:
	var statement := GdscriptProperty.new()
	statement.name = name
	statement.type = type
	statement.initial_value = default_value
	return statement


func generate_code() -> String:
	var code := "@export var " + super.generate_code()
	if setter != null:
		code += " : set = " + setter.name
	return code + "\n"
