@tool
class_name SignalReactivityTrigger
extends DataReactivityTrigger


@export var node_path : NodePath :
	set(value):
		node_path = value
		_update_resource_name()

@export var signal_path : String :
	set(value):
		signal_path = value
		_update_resource_name()


func _update_resource_name() -> void:
	resource_name = String(node_path) + " » " + signal_path if not node_path.is_empty() else signal_path
