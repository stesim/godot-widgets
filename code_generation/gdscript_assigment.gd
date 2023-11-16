@tool
class_name GdscriptAssignment
extends GdscriptStatement


@export var destination : GdscriptReference

@export var value : GdscriptExpression


@warning_ignore("shadowed_variable")
static func create(destination : GdscriptReference, value : GdscriptExpression) -> GdscriptAssignment:
	var statement := GdscriptAssignment.new()
	statement.destination = destination
	statement.value = value
	return statement


func generate_code() -> String:
	return destination.generate_code() + " = " + value.generate_code() + "\n"
