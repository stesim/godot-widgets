@tool
class_name PrimitiveShape
extends MeshInstance3D


func _get_shader_parameter(parameter : StringName) -> Variant:
	return get_surface_override_material(0).get_shader_parameter(parameter)


func _set_shader_parameter(parameter : StringName, value : Variant) -> void:
	get_surface_override_material(0).set_shader_parameter(parameter, value)
