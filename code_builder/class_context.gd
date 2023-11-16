@tool
class_name ClassContext
extends CodeContext


var _class : GdscriptClass


func get_class_code() -> GdscriptClass:
	return _class


func find_local_symbol(name : StringName) -> GdscriptSymbol:
	# TODO: return (cached) symbols of base type?
	for symbol in _class.symbols:
		if symbol.name == name:
			return symbol
	return null


func create_property(name : StringName, type : GdscriptType, initial_value : GdscriptExpression = null, is_export := false, is_onready := false) -> GdscriptProperty:
	var existing_symbol := find_symbol(name)
	if existing_symbol != null:
		if existing_symbol.context == self:
			push_warning("symbol name is already in use: " + name)
		else:
			push_warning("property shadows another symbol: " + name)

	var property := GdscriptProperty.new()
	property.name = name
	property.type = type
	property.initial_value = initial_value
	property.is_export = is_export
	property.is_onready = is_onready

	_class.symbols.push_back(property)

	return property


func create_export_property(name : StringName, type : GdscriptType, initial_value : GdscriptExpression = null) -> GdscriptProperty:
	return create_property(name, type, initial_value, true, false)


func create_onready_property(name : StringName, type : GdscriptType, initial_value : GdscriptExpression = null) -> GdscriptProperty:
	return create_property(name, type, initial_value, false, true)


func create_class(name : StringName, base_class : GdscriptType = null, is_tool := false) -> ClassContext:
	var existing_symbol := find_symbol(name)
	if existing_symbol != null:
		if existing_symbol.context == self:
			push_warning("class name is already in use: " + name)
		else:
			push_warning("class shadows another symbol: " + name)
	elif not _builder._is_global_name_available(name):
		push_warning("class name is already in use: " + name)

	var inner_class := GdscriptClass.new()
	inner_class.name = name
	inner_class.base_class = base_class
	inner_class.is_tool = is_tool

	_class.symbols.push_back(inner_class)
	return go_to_class(inner_class)


func create_function(name : StringName, parameters : Array[GdscriptParameter] = [], return_type : GdscriptType = null) -> FunctionContext:
	var existing_symbol := find_symbol(name)
	if existing_symbol != null:
		if existing_symbol.context == self:
			push_warning("symbol name is already in use: " + name)
		else:
			push_warning("function shadows another symbol: " + name)

	var function := GdscriptFunction.new()
	function.name = name
	function.parameters = parameters
	function.return_type = return_type
	function.body = GdscriptBlock.new()

	_class.symbols.push_back(function)
	return go_to_function(function)


func add_symbol(symbol : GdscriptSymbol) -> void:
	_class.symbols.push_back(symbol)


func go_to_class(class_ : GdscriptClass) -> ClassContext:
	if not class_ in _class.symbols:
		return null
	return ClassContext.new()._from_sub_scope(self, class_)


func go_to_function(function : GdscriptFunction) -> FunctionContext:
	if not function in _class.symbols:
		return null
	return FunctionContext.new()._from_sub_scope(self, function)


func _from_sub_scope(base : CodeContext, sub_scope : Variant) -> CodeContext:
	_class = sub_scope
	return super._from_sub_scope(base, sub_scope)
