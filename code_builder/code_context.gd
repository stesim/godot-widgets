@tool
class_name CodeContext
extends RefCounted


const MAX_UNIQUE_NAME_TRIES := 100


var _builder : CodeBuilder

var _parent_scopes : Array[CodeContext] = []


func get_builder() -> CodeBuilder:
	return _builder


func get_parent_context() -> CodeContext:
	return _parent_scopes[0] if not _parent_scopes.is_empty() else null


func find_symbol(name : StringName) -> ScopedSymbol:
	var symbol :=  find_local_symbol(name)
	var symbol_context := self

	if symbol == null:
		for context in _parent_scopes:
			symbol = context.find_local_symbol(name)
			if symbol != null:
				symbol_context = context
				break

	if symbol == null:
		return null

	var scoped_symbol := ScopedSymbol.new()
	scoped_symbol.symbol = symbol
	scoped_symbol.context = symbol_context
	return scoped_symbol


func to_unique_symbol_name(name : String, hint := "") -> StringName:
	var symbol_name := CodeContext.to_symbol_name(name)

	if find_symbol(symbol_name) == null:
		return symbol_name

	if not hint.is_empty():
		symbol_name = CodeContext.to_symbol_name(symbol_name + "_" + hint)
		if find_symbol(symbol_name) == null:
			return symbol_name

	for i in MAX_UNIQUE_NAME_TRIES:
		var candidate := StringName(symbol_name + "_" + str(2 + i))
		if find_symbol(candidate) == null:
			return candidate

	push_error("failed to create unique symbol name")
	return symbol_name


@warning_ignore("unused_parameter")
func find_local_symbol(name : StringName) -> GdscriptSymbol:
	return null


@warning_ignore("unused_parameter")
func _from_sub_scope(base : CodeContext, sub_scope : Variant) -> CodeContext:
	if base != null:
		_builder = base._builder
		_parent_scopes = [base]
		_parent_scopes.append_array(base._parent_scopes)
	return self


static func to_symbol_name(name : String) -> StringName:
	return _sanitize_symbol_name(name).to_snake_case()


static func _sanitize_symbol_name(dirty_name : String) -> String:
	return SYMBOL_NAME_REGEX.sub(dirty_name, "_", true)


static var SYMBOL_NAME_REGEX := _create_symbol_name_regex()

static func _create_symbol_name_regex() -> RegEx:
	var regex = RegEx.new()
	regex.compile("\\W+")
	return regex



class ScopedSymbol extends RefCounted:
	var symbol : GdscriptSymbol

	var context : CodeContext
