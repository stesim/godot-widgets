@tool
class_name DataWriter
extends DataProcessor


@export var target_path : NodePath

@export var property_path : String


func _process(context : Node, value : Variant) -> Variant:
	var target := context.get_node_or_null(target_path)
	if target != null:
		# TODO: cache property_path as NodePath
		target.set_indexed(NodePath(property_path), value)
	return value
