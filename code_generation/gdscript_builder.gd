@tool
class_name GdscriptBuilder
extends Resource


const MAX_UNIQUE_NAME_TRIES := 100


@export var is_tool : bool :
	get: return _script.is_tool
	set(value): _script.is_tool = value

@export var global_name : StringName :
	get: return _script.global_name
	set(value): _script.global_name = value

@export var base_class : GdscriptType :
	get: return _script.base_class
	set(value): _script.base_class = value


var _script := GdscriptScript.new()

var _symbols_by_name := {}

var _object_types := {}


func add_function(function : GdscriptFunction) -> void:
	_add_symbol(function)


func add_property(property : GdscriptProperty) -> void:
	_add_symbol(property)


func has_symbol(name : StringName) -> bool:
	return _symbols_by_name.has(name)


func to_unique_symbol_name(name : String, hint := "") -> StringName:
	# TODO: consider scope
	# TODO: consider base class symbols

	var symbol_name := GdscriptBuilder.to_symbol_name(name)

	if not has_symbol(symbol_name):
		return symbol_name

	if not hint.is_empty():
		symbol_name += "_" + hint
		if not has_symbol(symbol_name):
			return symbol_name

	for i in MAX_UNIQUE_NAME_TRIES:
		var candidate := StringName(symbol_name + "_" + str(2 + i))
		if not has_symbol(candidate):
			return candidate

	push_error("failed to create unique symbol name")
	return symbol_name


func get_object_type(name : StringName) -> GdscriptType:
	var type : GdscriptType = _object_types.get(name)
	if type == null:
		type = GdscriptType.new()
		type.base = GdscriptType.Base.OBJECT
		type.specialization = name
		_object_types[name] = type
	return type


func generate_code() -> String:
	return _script.generate_code()


static func to_symbol_name(name : String) -> StringName:
	return _sanitize_symbol_name(name).to_snake_case()


func _add_symbol(symbol : GdscriptSymbol) -> void:
	_script.symbols.push_back(symbol)
	_symbols_by_name[symbol.name] = symbol


static func _sanitize_symbol_name(dirty_name : String) -> String:
	return SYMBOL_NAME_REGEX.sub(dirty_name, "_", true)


static var SYMBOL_NAME_REGEX := _create_symbol_name_regex()

static func _create_symbol_name_regex() -> RegEx:
	var regex = RegEx.new()
	regex.compile("\\W+")
	return regex
