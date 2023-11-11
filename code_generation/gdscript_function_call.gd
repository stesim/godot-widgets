@tool
class_name GdscriptFunctionCall
extends GdscriptExpression


@export var function : GdscriptFunction

@export var arguments : Array[GdscriptExpression] = []

@export var object : GdscriptExpression


@warning_ignore("shadowed_variable")
static func create(function : GdscriptFunction, arguments : Array[GdscriptExpression], object : GdscriptExpression = null) -> GdscriptFunctionCall:
	var expression := GdscriptFunctionCall.new()
	expression.function = function
	expression.arguments = arguments
	expression.object = object
	return expression


func generate_code() -> String:
	var code := ""
	if object != null:
		code += object.generate_code() + "."
	code += function.name + "("
	for i in arguments.size():
		if i > 0:
			code += ", "
		code += arguments[i].generate_code()
	code += ")"
	return code
