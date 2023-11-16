@tool
class_name FunctionContext
extends CodeContext


var _function : GdscriptFunction


func get_function_code() -> GdscriptFunction:
	return _function


func find_local_symbol(name : StringName) -> GdscriptSymbol:
	for symbol in _function.parameters:
		if symbol.name == name:
			return symbol
	return super.find_local_symbol(name)


func go_to_body() -> BlockContext:
	if _function.body == null:
		return null

	return BlockContext.new()._from_sub_scope(self, _function.body)


func _from_sub_scope(base : CodeContext, sub_scope : Variant) -> CodeContext:
	_function = sub_scope
	return super._from_sub_scope(base, _function)
