@tool
extends PrimitiveShape


enum SamplingMode {
	LINEAR = 0,
	RADIAL = 1,
	CONIC = 2,
	TUBULAR = 3,
}


@export var size := Vector2.ONE :
	get:
		return Vector2(scale.x, scale.y)
	set(value):
		scale.x = value.x
		scale.y = value.y

@export_range(0.0, 1.0) var fill_fraction := 1.0 :
	get:
		return 1.0 - _get_shader_parameter(&"inner_radius")
	set(value):
		_set_shader_parameter(&"inner_radius", 1.0 - value)

@export_range(0.0, 1.0) var arc_fraction := 1.0 :
	get:
		return _get_shader_parameter(&"arc_angle")
	set(value):
		_set_shader_parameter(&"arc_angle", value)

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

@export var sampling_mode : SamplingMode :
	get:
		return _get_shader_parameter(&"sampling_mode")
	set(value):
		_set_shader_parameter(&"sampling_mode", value)

@export var clamp_radius := true :
	get:
		return _get_shader_parameter(&"clamp_radius")
	set(value):
		_set_shader_parameter(&"clamp_radius", value)

@export var clamp_angle := true :
	get:
		return _get_shader_parameter(&"clamp_angle")
	set(value):
		_set_shader_parameter(&"clamp_angle", value)

@export_range(0.0, 0.1) var anti_alias_size := 0.005 :
	get:
		return _get_shader_parameter(&"anti_alias_size")
	set(value):
		_set_shader_parameter(&"anti_alias_size", value)
