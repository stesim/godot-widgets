@tool
class_name DataTransform
extends DataProcessor


static var INPUT_NAMES := PackedStringArray(["value"])


@export_multiline var expression := "" :
	set(value):
		if expression != value:
			expression = value
			_is_dirty = true


var _expression := Expression.new()

var _is_dirty := true

var _is_valid := false


func _process(context : Node, value : Variant) -> Variant:
	if _is_dirty:
		_recompile()
		_is_dirty = false

	if not _is_valid:
		push_error("invalid data transform expression; returning null")

	return _expression.execute([value], context)


func _recompile() -> void:
	var error := _expression.parse(expression, INPUT_NAMES)
	_is_valid = error == OK
	if not _is_valid:
		push_error("failed to parse data transform expression -- ", error_string(error))
