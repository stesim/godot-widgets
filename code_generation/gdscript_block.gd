@tool
class_name GdscriptBlock
extends Resource


@export var statements : Array[GdscriptStatement] = []


func generate_code() -> String:
	if statements.is_empty():
		return "pass\n"

	var code := ""
	for statement in statements:
		code += statement.generate_code()
	return code
