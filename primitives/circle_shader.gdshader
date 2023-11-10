shader_type spatial;
render_mode unshaded, blend_mix;


const int SAMPLING_LINEAR = 0;
const int SAMPLING_RADIAL = 1;
const int SAMPLING_CONIC = 2;
const int SAMPLING_TUBULAR = 3;


uniform float inner_radius : hint_range(0.0, 1.0) = 0.0;

uniform float arc_angle : hint_range(0.0, 1.0) = 1.0;

uniform vec4 fill_color : source_color = vec4(1.0);

uniform sampler2D fill_texture : source_color, repeat_disable;

uniform int sampling_mode : hint_range(0, 2) = 0;

uniform bool clamp_radius = true;

uniform bool clamp_angle = true;

uniform float anti_alias_size = 0.005;


float linear_step(float edge0, float edge1, float x) {
	return clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
}

vec2 to_polar(float radius, float angle) {
	vec2 polar_uv = vec2(
		clamp_radius ? linear_step(inner_radius, 1.0, radius) : radius,
		clamp_angle ? angle / arc_angle : angle
	);
	return polar_uv;
}

void fragment() {
	vec2 normalized_position = 2.0 * UV - 1.0;

	float radius = length(normalized_position);
	float inner_coverage = linear_step(inner_radius - anti_alias_size, inner_radius, radius);
	float outer_coverage = 1.0 - linear_step(1.0 - anti_alias_size, 1.0, radius);
	ALPHA = inner_coverage * outer_coverage;

	float signed_angle = atan(normalized_position.y, normalized_position.x) / TAU;
	float angle = signed_angle + 0.5;
	if (arc_angle < 1.0) {
		float arc_anti_alias_size = anti_alias_size / (TAU * radius);
		float arc_start_coverage = linear_step(0.0, arc_anti_alias_size, angle);
		float arc_end_coverage = 1.0 - linear_step(arc_angle - arc_anti_alias_size, arc_angle, angle);
		ALPHA *= arc_start_coverage * arc_end_coverage;
	}

	vec2 sample_uv = UV;
	switch (sampling_mode) {
		case SAMPLING_RADIAL: sample_uv = to_polar(radius, angle); break;
		case SAMPLING_CONIC: sample_uv = to_polar(radius, angle).yx; break;
		case SAMPLING_TUBULAR:
			sample_uv = to_polar(radius, angle);
			sample_uv.x = acos(1.0 - 2.0 * sample_uv.x) / PI;
			break;
	}

	vec4 albedo = fill_color * textureLod(fill_texture, sample_uv, 0);
	ALBEDO = albedo.rgb;
	ALPHA *= albedo.a;
}
