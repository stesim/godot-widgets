@tool
class_name DataBinding
extends Resource


@export var target_path : NodePath :
	set(value):
		target_path = value
		_update_resource_name()

@export var property_path : String :
	set(value):
		property_path = value
		_update_resource_name()

@export var source : DataSource


func _update_resource_name() -> void:
	resource_name = String(target_path) + " » " + property_path if not target_path.is_empty() else property_path
