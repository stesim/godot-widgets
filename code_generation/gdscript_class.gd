@tool
class_name GdscriptClass
extends GdscriptSymbol


@export var is_tool := false

@export var base_class : GdscriptType

@export var symbols : Array[GdscriptSymbol] = []


func generate_code() -> String:
	var code := ""
	code += _generate_preamble()
	code += _generate_symbols().indent("\t") if not symbols.is_empty() else "\tpass\n"
	return code


func _generate_preamble() -> String:
	var code := ""

	if is_tool:
		code += "@tool\n"

	code += "class " + name

	if base_class != null:
		code += " extends " + base_class.generate_code()

	code += ":\n"

	return code


# TODO: provide ability to control formatting
func _generate_symbols() -> String:
	var code := ""

	# HACK: sort symbols into different categories for better readability

	var symbols_by_category : Array[Array] = [
		[], # inner classes
		[], # export properties
		[], # public properties
		[], # onready properties
		[], # private properties
		[], # public functions
		[], # private functions
	]

	for symbol in symbols:
		var category := symbols_by_category.size() - 1
		if symbol is GdscriptClass:
			category = 0
		if symbol is GdscriptProperty:
			if symbol.is_export:
				category = 1
			elif not symbol.name.begins_with("_"):
				category = 2
			elif symbol.is_onready:
				category = 3
			else:
				category = 4
		elif symbol is GdscriptFunction:
			if not symbol.name.begins_with("_"):
				category = 5
			else:
				category = 6
		symbols_by_category[category].push_back(symbol)

	for i in symbols_by_category.size():
		var category := symbols_by_category[i]
		var is_function_category := i >= 5
		for symbol in category:
			code += symbol.generate_code() + "\n"
			if is_function_category:
				code += "\n"
		if not category.is_empty() and i < symbols_by_category.size() - 1:
			code += "\n"

	return code
