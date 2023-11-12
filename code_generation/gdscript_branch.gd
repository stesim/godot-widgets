@tool
class_name GdscriptBranch
extends GdscriptStatement


@export var condition : GdscriptExpression

@export var then_statements : Array[GdscriptStatement] = []

@export var elif_branches : Array[GdscriptBranch] = []

@export var else_statements : Array[GdscriptStatement] = []


@warning_ignore("shadowed_variable")
static func create(condition : GdscriptExpression, then_statements : Array[GdscriptStatement], else_statements : Array[GdscriptStatement] = [], elif_branches : Array[GdscriptBranch] = []) -> GdscriptBranch:
	var statement := GdscriptBranch.new()
	statement.condition = condition
	statement.then_statements = then_statements
	statement.elif_branches = elif_branches
	statement.else_statements = else_statements
	return statement


func generate_code() -> String:
	var code := "if " + condition.generate_code() + ":\n"
	code += _stringify_block(then_statements)

	for branch in elif_branches:
		assert(branch.elif_branches.is_empty())
		assert(branch.else_statements.is_empty())
		code += "elif " + branch.condition.generate_code() + ":\n"
		code += _stringify_block(branch.then_statements)

	if not else_statements.is_empty():
		code += "else:\n"
		code += _stringify_block(else_statements)

	return code


func _stringify_block(statements : Array[GdscriptStatement]) -> String:
	var code := ""
	for statement in statements:
		code += statement.generate_code()
	return code.indent("\t")
