@tool
class_name GdscriptFunction
extends Resource


@export var name : StringName

@export var parameters : Array[GdscriptSymbol] = []

@export var return_type : GdscriptType = null

@export var body : Array[GdscriptStatement] = []

@export var is_external := false


@warning_ignore("shadowed_variable")
static func create_external(name : StringName) -> GdscriptFunction:
	var function := GdscriptFunction.new()
	function.name = name
	return function


func generate_code() -> String:
	assert(not is_external)

	var code := "func " + name + "("
	for i in parameters.size():
		if i > 0:
			code += ", "
		code += parameters[i].generate_code()
	code += ")"
	if return_type != null:
		code += " -> " + return_type.generate_code()
	code += ":\n"
	if body.is_empty():
		code += "\tpass\n"
	else:
		for statement in body:
			code += "\t" + statement.generate_code()
	return code
