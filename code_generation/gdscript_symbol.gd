@tool
class_name GdscriptSymbol
extends GdscriptStatement


@export var name : StringName

@export var type : GdscriptType

@export var initial_value : GdscriptExpression


func generate_code() -> String:
	var code := name
	if type != null:
		code += " : " + type.generate_code()
	if initial_value != null:
		code += " = " if type != null else " := "
		code += initial_value.generate_code()
	return code
