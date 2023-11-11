@tool
class_name GdscriptAssignment
extends GdscriptStatement


@export var symbol : GdscriptSymbol

@export var value : GdscriptExpression

@export var object : GdscriptExpression


@warning_ignore("shadowed_variable")
static func create(symbol : GdscriptSymbol, value : GdscriptExpression, object : GdscriptExpression = null) -> GdscriptAssignment:
	var statement := GdscriptAssignment.new()
	statement.symbol = symbol
	statement.value = value
	statement.object = object
	return statement


func generate_code() -> String:
	assert(symbol != null)
	assert(value != null)
	var code := ""
	if object != null:
		code += object.generate_code() + "."
	code += symbol.name + " = " + value.generate_code() + "\n"
	return code
