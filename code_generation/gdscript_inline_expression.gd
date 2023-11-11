@tool
class_name GdscriptInlineExpression
extends GdscriptExpression


@export var code := ""


static func create(source_code : String) -> GdscriptInlineExpression:
	var expression := GdscriptInlineExpression.new()
	expression.code = source_code
	return expression


func generate_code() -> String:
	return code
