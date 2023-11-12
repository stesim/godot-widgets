@tool
class_name GdscriptFunctionCall
extends GdscriptExpression


@export var function : GdscriptExpression

@export var arguments : Array[GdscriptExpression] = []


@warning_ignore("shadowed_variable")
static func create(function : GdscriptExpression, arguments : Array[GdscriptExpression] = []) -> GdscriptFunctionCall:
	var expression := GdscriptFunctionCall.new()
	expression.function = function
	expression.arguments = arguments
	return expression


func generate_code() -> String:
	var code := ""
	code += function.generate_code() + "("
	for i in arguments.size():
		if i > 0:
			code += ", "
		code += arguments[i].generate_code()
	code += ")"
	return code
