@tool
class_name GdscriptScript
extends GdscriptClass


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

	if not name.is_empty():
		code += "class_name " + name + "\n"

	if base_class != null:
		code += "extends " + base_class.generate_code() + "\n"

	return code
