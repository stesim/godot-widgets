@tool
class_name GdscriptReturn
extends GdscriptStatement


@export var value : GdscriptExpression


static func create(value_ : GdscriptExpression) -> GdscriptReturn:
	var statement := GdscriptReturn.new()
	statement.value = value_
	return statement


func generate_code() -> String:
	var code := "return"
	if value != null:
		code += " " + value.generate_code()
	code += "\n"
	return code
