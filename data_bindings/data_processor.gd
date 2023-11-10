@tool
class_name DataProcessor
extends Resource


@export var name : StringName :
	get:
		return resource_name
	set(value):
		resource_name = value

@export var disabled := false


func process(context : Node, value : Variant) -> Variant:
	return _process(context, value) if not disabled else value


@warning_ignore("unused_parameter")
func _process(context : Node, value : Variant) -> Variant:
	return value
