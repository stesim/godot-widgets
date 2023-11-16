@tool
class_name GdscriptBranch
extends GdscriptStatement


@export var condition : GdscriptExpression

@export var then_block : GdscriptBlock

@export var elif_branches : Array[GdscriptBranch] = []

@export var else_block : GdscriptBlock = null


@warning_ignore("shadowed_variable")
static func create(condition : GdscriptExpression, then_block : GdscriptBlock, else_block : GdscriptBlock = null, elif_branches : Array[GdscriptBranch] = []) -> GdscriptBranch:
	var statement := GdscriptBranch.new()
	statement.condition = condition
	statement.then_block = then_block
	statement.elif_branches = elif_branches
	statement.else_block = else_block
	return statement


func generate_code() -> String:
	var code := "if " + condition.generate_code() + ":\n"
	code += then_block.generate_code().indent("\t") if then_block != null else "\tpass\n"

	for branch in elif_branches:
		assert(branch.elif_branches.is_empty())
		assert(branch.else_block.statements.is_empty())
		code += "elif " + branch.condition.generate_code() + ":\n"
		code += branch.then_block.generate_code().indent("\t") if branch.then_block != null else "\tpass\n"

	if else_block != null and not else_block.statements.is_empty():
		code += "else:\n"
		code += else_block.generate_code().indent("\t")

	return code
