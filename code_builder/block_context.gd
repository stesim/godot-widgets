@tool
class_name BlockContext
extends CodeContext


var _block : GdscriptBlock


func get_block_code() -> GdscriptBlock:
	return _block


func create_variable(name : StringName, type : GdscriptType, initial_value : GdscriptExpression = null) -> GdscriptVariable:
	var existing_symbol := find_symbol(name)
	if existing_symbol != null:
		if existing_symbol.context == self:
			push_warning("variable name is already in use: " + name)
		else:
			push_warning("variable shadows another symbol: " + name)

	var variable := GdscriptVariable.new()
	variable.name = name
	variable.type = type
	variable.initial_value = initial_value

	_block.statements.push_back(variable)
	return variable


func create_assignment(destination : GdscriptReference, value : GdscriptExpression) -> GdscriptAssignment:
	var assignment := GdscriptAssignment.new()
	assignment.destination = destination
	assignment.value = value

	_block.statements.push_back(assignment)
	return assignment


func create_function_call(function : GdscriptExpression, arguments : Array[GdscriptExpression] = []) -> GdscriptExpressionStatement:
	var function_call := GdscriptFunctionCall.new()
	function_call.function = function
	function_call.arguments = arguments

	return create_expression_statement(function_call)


func create_expression_statement(expression : GdscriptExpression) -> GdscriptExpressionStatement:
	var statement := GdscriptExpressionStatement.new()
	statement.expression = expression

	_block.statements.push_back(statement)
	return statement


func create_return(value : GdscriptExpression) -> GdscriptReturn:
	var statement := GdscriptReturn.new()
	statement.value = value

	_block.statements.push_back(statement)
	return statement


func add_statement(statement : GdscriptStatement) -> void:
	_block.statements.push_back(statement)


func find_local_symbol(name : StringName) -> GdscriptSymbol:
	for statement in _block.statements:
		if statement is GdscriptVariable and statement.name == name:
			return statement
	return null


func go_to_branch(branch : GdscriptBranch) -> BranchContext:
	for statement in _block.statements:
		if statement == branch:
			return BranchContext.new()._from_sub_scope(self, branch)
	return null


func _from_sub_scope(base : CodeContext, sub_scope : Variant) -> CodeContext:
	_block = sub_scope
	return super._from_sub_scope(base, sub_scope)
