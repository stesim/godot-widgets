@tool
class_name GdscriptReference
extends GdscriptExpression


@export var symbol : GdscriptSymbol

@export var object : GdscriptExpression


@warning_ignore("shadowed_variable")
static func create(symbol : GdscriptSymbol, object : GdscriptExpression = null) -> GdscriptReference:
	var expression := GdscriptReference.new()
	expression.symbol = symbol
	expression.object = object
	return expression


func generate_code() -> String:
	var code := ""
	if object != null:
		code += object.generate_code() + "."
	code += symbol.name
	return code
