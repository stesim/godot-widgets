@tool
class_name GdscriptScript
extends Resource


@export var is_tool := false

@export var global_name : StringName

@export var base_class : GdscriptType

@export var symbols : Array[GdscriptSymbol] = []


func generate_code() -> String:
	var code := ""
	code += _generate_preamble()
	code += "\n\n"
	code += _generate_symbols()
	return code


func _generate_preamble() -> String:
	var code := ""

	if is_tool:
		code += "@tool\n"

	if not global_name.is_empty():
		code += "class_name " + global_name + "\n"

	if base_class != null:
		code += "extends " + base_class.generate_code() + "\n"

	return code


# TODO: provide ability to control formatting
func _generate_symbols() -> String:
	var code := ""

	# HACK: sort symbols into different categories for better readability

	var symbols_by_category : Array[Array] = [
		[], # export properties
		[], # public properties
		[], # onready properties
		[], # private properties
		[], # public functions
		[], # private functions
	]

	for symbol in symbols:
		var category := symbols_by_category.size() - 1
		if symbol is GdscriptProperty:
			if symbol.is_export:
				category = 0
			elif not symbol.name.begins_with("_"):
				category = 1
			elif symbol.is_onready:
				category = 2
			else:
				category = 3
		elif symbol is GdscriptFunction:
			if not symbol.name.begins_with("_"):
				category = 4
			else:
				category = 5
		symbols_by_category[category].push_back(symbol)

	for i in symbols_by_category.size():
		var category := symbols_by_category[i]
		var is_function_category := i >= 4
		for symbol in category:
			code += symbol.generate_code() + "\n"
			if is_function_category:
				code += "\n"
		if not category.is_empty() and i < symbols_by_category.size() - 1:
			code += "\n"

	return code
