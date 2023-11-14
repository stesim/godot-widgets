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


@export_group("Reactivity")

@export var ignore_implicit_triggers := false

@export var explicit_triggers : Array[DataReactivityTrigger] = []


func _init() -> void:
	_update_resource_name()


func _update_resource_name() -> void:
	resource_name = String(target_path) if property_path.is_empty() else String(target_path) + " » " + property_path
