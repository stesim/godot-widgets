@tool
class_name GdscriptFunction
extends GdscriptSymbol


@export var parameters : Array[GdscriptParameter] = []

@export var return_type : GdscriptType = null

@export var body : Array[GdscriptStatement] = []

@export var is_external := false


@warning_ignore("shadowed_variable")
static func create(name : StringName, parameters : Array[GdscriptParameter] = [], return_type : GdscriptType = null, body : Array[GdscriptStatement] = []) -> GdscriptFunction:
	var function := GdscriptFunction.new()
	function.name = name
	function.parameters = parameters
	function.return_type = return_type
	function.body = body
	return function


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
			code += statement.generate_code().indent("\t")
	return code
