@tool
class_name GdscriptBuilder
extends Resource


@export var is_tool := false

@export var global_name : StringName

@export var inherits : StringName

@export var properties : Array[GdscriptProperty] = []

@export var functions : Array[GdscriptFunction] = []


func generate_code() -> String:
	var code := ""

	if is_tool:
		code += "@tool\n"

	if not global_name.is_empty():
		code += "class_name " + global_name + "\n"

	if not inherits.is_empty():
		code += "extends " + inherits + "\n\n\n"

	for property in properties:
		code += property.generate_code() + "\n"

	code += "\n"

	for function in functions:
		code += function.generate_code() + "\n\n"

	return code
