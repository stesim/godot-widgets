@tool
class_name FunctionCallProcessor
extends DataProcessor


enum ValueParameterPosition {
	NONE,
	FRONT,
	END,
}


@export var target_path : NodePath

@export var function_path : String

@export var pass_value := false

@export var transform_value := false


func _process(context : Node, value : Variant) -> Variant:
	var target := context.get_node_or_null(target_path)
	if target == null:
		return null
	# TODO: cache function_path as NodePath
	var method : Variant = target.get_indexed(function_path)
	if not method is Callable:
		push_error("function path target is not callable")
		return null
	var result : Variant = method.call(value) if pass_value else method.call()
	return result if transform_value else value
