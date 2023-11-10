@tool
extends PrimitiveShape


@export var size := Vector2.ONE :
	get:
		return Vector2(scale.x, scale.y)
	set(value):
		scale.x = value.x
		scale.y = value.y

@export var fill_fraction := Vector2.ONE :
	get:
		return Vector2.ONE - _get_shader_parameter(&"inner_size")
	set(value):
		_set_shader_parameter(&"inner_size", Vector2.ONE - _clamp_0_1(value))

@export var outer_rounding := Vector2.ZERO :
	get:
		return _get_shader_parameter(&"outer_rounding")
	set(value):
		_set_shader_parameter(&"outer_rounding", _clamp_0_1(value))

@export var inner_rounding := Vector2.ZERO :
	get:
		return _get_shader_parameter(&"inner_rounding")
	set(value):
		_set_shader_parameter(&"inner_rounding", _clamp_0_1(value))

@export var fill_color := Color.WHITE :
	get:
		return _get_shader_parameter(&"fill_color")
	set(value):
		_set_shader_parameter(&"fill_color", value)

@export var fill_texture : Texture2D :
	get:
		return _get_shader_parameter(&"fill_texture")
	set(value):
		_set_shader_parameter(&"fill_texture", value)

@export_range(0.0, 0.1) var anti_alias_size := 0.005 :
	get:
		return _get_shader_parameter(&"anti_alias_size")
	set(value):
		_set_shader_parameter(&"anti_alias_size", value)


func _clamp_0_1(vector : Vector2) -> Vector2:
	return vector.clamp(Vector2.ZERO, Vector2.ONE)
