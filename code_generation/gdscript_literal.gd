@tool
class_name GdscriptLiteral
extends GdscriptExpression


var value : Variant = null


static func create(value_ : Variant) -> GdscriptLiteral:
	var statement := GdscriptLiteral.new()
	statement.value = value_
	return statement


func generate_code() -> String:
	return _stringify_value(value)


func _stringify_value(value_ : Variant) -> String:
	match typeof(value_):
		TYPE_BOOL, TYPE_INT:
			return str(value_)
		TYPE_FLOAT:
			return _stringify_float(value_)
		TYPE_STRING:
			return "\"" + value_.replace("\"", "\\\"") + "\""
		TYPE_STRING_NAME:
			return "&" + _stringify_value(String(value_))
		TYPE_NODE_PATH:
			return "^" + _stringify_value(String(value_))
		TYPE_ARRAY:
			return _stringify_array(value_)
		TYPE_NIL:
			return "null"
		TYPE_OBJECT: # HACK: serialize objects as null
			return "null"
	assert(false)
	return ""


func _stringify_float(value_ : float) -> String:
	var has_fractional_part := value_ != float(int(value_))
	var stringified := "%.16f" % value_ if has_fractional_part else str(value_) + ".0"
	var string_length := stringified.length()
	var last_nonzero_position := string_length - 1
	while last_nonzero_position > 0 and stringified[last_nonzero_position] == "0":
		last_nonzero_position -= 1
	if stringified[last_nonzero_position] == ".":
		last_nonzero_position += 1
	var significant_length := last_nonzero_position + 1
	if significant_length < string_length:
		stringified = stringified.substr(0, significant_length)
	return stringified


# NOTE: needs to take Variant parameter as array may be typed
func _stringify_array(array : Variant) -> String:
	var code := "["
	for i in array.size():
		if i > 0:
			code += ", "
		code += _stringify_value(array[i])
	code += "]"
	return code
