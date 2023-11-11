@tool
class_name GdscriptExpressionStatement
extends GdscriptStatement


@export var expression : GdscriptExpression


@warning_ignore("shadowed_variable")
static func create(expression : GdscriptExpression) -> GdscriptExpressionStatement:
	var statement := GdscriptExpressionStatement.new()
	statement.expression = expression
	return statement


func generate_code() -> String:
	return expression.generate_code() + "\n"
