shader_type spatial;
render_mode unshaded, blend_mix;


uniform vec2 inner_size = vec2(0.0, 0.0);

uniform vec2 outer_rounding = vec2(0.0, 0.0);

uniform vec2 inner_rounding = vec2(0.0, 0.0);

uniform vec4 fill_color : source_color = vec4(1.0);

uniform sampler2D fill_texture : source_color, repeat_disable;

uniform float anti_alias_size = 0.005;


float linear_step(float edge0, float edge1, float x) {
	return clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
}

vec2 linear_step_2(vec2 edge0, vec2 edge1, vec2 x) {
	return clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
}

float compute_rounding_coverage(vec2 size, vec2 rounding, vec2 unsigned_position) {
	bool is_rounded = all(greaterThan(rounding, vec2(0.01)));
	float coverage;
	if (!is_rounded) {
		vec2 per_axis_coverage = 1.0 - linear_step_2(size - anti_alias_size, size, unsigned_position);
		coverage = per_axis_coverage.x * per_axis_coverage.y;
	} else {
		vec2 scaled_rounding = size * rounding;
		vec2 rounding_center = size - scaled_rounding;
		vec2 normalized_offset = max((unsigned_position - rounding_center), 0.0) / scaled_rounding;
		float normalized_distance = length(normalized_offset);
		float weighted_outer_rounding = dot(normalized_offset / normalized_distance, scaled_rounding);
		float rounding_anti_alias_size = anti_alias_size / weighted_outer_rounding;
		coverage = 1.0 - linear_step(1.0 - rounding_anti_alias_size, 1.0, normalized_distance);
	}
	return coverage;
}

void fragment() {
	vec2 normalized_position = 2.0 * UV - 1.0;
	vec2 unsigned_position = abs(normalized_position);
	ALPHA = compute_rounding_coverage(vec2(1.0), outer_rounding, unsigned_position);
	ALPHA *= 1.0 - compute_rounding_coverage(inner_size, inner_rounding, unsigned_position);

	vec2 sample_uv = UV;
	vec4 albedo = fill_color * texture(fill_texture, sample_uv);
	ALBEDO = albedo.rgb;
	ALPHA *= albedo.a;
}
