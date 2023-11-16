@tool
class_name CodeBuilder
extends RefCounted


var _scripts : Array[GdscriptScript] = []

var _cached_object_types := {}

var _cached_array_types := {}

var _cached_external_symbol_references := {}


func get_object_type(type_name : StringName) -> GdscriptType:
	if type_name.is_empty():
		return null

	var type : GdscriptType = _cached_object_types.get(type_name)

	if type == null:
		if _is_global_name_available(type_name):
			push_warning("class name does not exist: " + type_name)
		type = GdscriptType.new()
		type.base = GdscriptType.Base.OBJECT
		type.specialization = type_name
		_cached_object_types[type_name] = type

	return type


func get_array_type(element_type_name : StringName) -> GdscriptType:
	var type : GdscriptType = _cached_array_types.get(element_type_name)

	if type == null:
		if not element_type_name.is_empty() and _is_global_name_available(element_type_name):
			push_warning("class name does not exist: " + element_type_name)
		type = GdscriptType.new()
		type.base = GdscriptType.Base.ARRAY
		type.specialization = element_type_name
		_cached_array_types[element_type_name] = type

	return type


func get_primitive_type(primitive_type : GdscriptType.Base) -> GdscriptType:
	match primitive_type:
		GdscriptType.Base.BOOL: return GdscriptType.BOOL
		GdscriptType.Base.INT: return GdscriptType.INT
		GdscriptType.Base.FLOAT: return GdscriptType.FLOAT
		GdscriptType.Base.STRING: return GdscriptType.STRING
		GdscriptType.Base.VECTOR2: return GdscriptType.VECTOR2
		GdscriptType.Base.COLOR: return GdscriptType.COLOR

	push_error("unknown primitive type")
	return null


func get_external_symbol_reference(name : StringName) -> GdscriptReference:
	var ref : GdscriptReference = _cached_external_symbol_references.get(name)

	if ref == null:
		var symbol := GdscriptSymbol.new()
		symbol.name = name
		ref = GdscriptReference.new()
		ref.symbol = symbol
		_cached_external_symbol_references[name] = ref

	return ref


func get_external_symbol(name : StringName) -> GdscriptSymbol:
	return get_external_symbol_reference(name).symbol


func create_script(global_name := &"", base_class : GdscriptType = null, is_tool := false) -> ScriptContext:
	if not global_name.is_empty() and not _is_global_name_available(global_name):
		push_warning("class name is already in use: " + global_name)

	var script := GdscriptScript.new()
	script.name = global_name
	script.base_class = base_class
	script.is_tool = is_tool

	_scripts.push_back(script)

	return create_script_context(script)


func create_script_context(script : GdscriptScript) -> ScriptContext:
	if not script in _scripts:
		return null
	var context := ScriptContext.new()
	context._builder = self
	context._from_sub_scope(null, script)
	return context


func generate_code() -> Dictionary:
	var script_codes := {}
	for script in _scripts:
		script_codes[script] = script.generate_code()
	return script_codes


func _is_global_name_available(name : StringName) -> bool:
	if ClassDB.class_exists(name):
		return false
	for script in _scripts:
		if script.name == name:
			return false
	return true
