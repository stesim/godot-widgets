@tool
extends Node3D


@export var max_speed : float = 0.0

@export var speed : float = 0.0 : set = _set_speed

@export var speed_units : String = "" : set = _set_speed_units

@export var speed_limit : float = 0.0

@export var warning_range : float = 0.0

@export var warning_gradient : Resource = null


func _set_speed(value : float) -> void:
	speed = value
	_update_sequence(speed)


func _update_sequence(value : Variant) -> Variant:
	var processed_value : Variant = value
	processed_value = _ensure_non_negative(processed_value)
	processed_value = _update_arc(processed_value)
	processed_value = _update_label(processed_value)
	processed_value = _update_warning(processed_value)
	return value


func _ensure_non_negative(value : Variant) -> Variant:
	return maxf(0.0, value)


func _update_arc(value : Variant) -> Variant:
	var processed_value : Variant = value
	processed_value = _map_range(processed_value)
	processed_value = _set_arc_fraction(processed_value)
	return value


func _map_range(value : Variant) -> Variant:
	return 0.75 * clampf(value / max_speed, 0.0, 1.0)


func _set_arc_fraction(value : Variant) -> Variant:
	var target : Node = get_node(^"ring_gauge")
	target.arc_fraction = value
	return value


func _update_label(value : Variant) -> Variant:
	var processed_value : Variant = value
	processed_value = _stringify(processed_value)
	processed_value = _set_label_text(processed_value)
	return value


func _stringify(value : Variant) -> Variant:
	return str(int(value))


func _set_label_text(value : Variant) -> Variant:
	var target : Node = get_node(^"speed_label")
	target.text = value
	return value


func _update_warning(value : Variant) -> Variant:
	var processed_value : Variant = value
	processed_value = _map_to_0_1_(processed_value)
	processed_value = _sample_gradient(processed_value)
	processed_value = _set_label_color(processed_value)
	return value


func _map_to_0_1_(value : Variant) -> Variant:
	return (value - speed_limit) / warning_range


func _sample_gradient(value : Variant) -> Variant:
	return warning_gradient.sample(value)


func _set_label_color(value : Variant) -> Variant:
	var target : Node = get_node(^"speed_label")
	target.modulate = value
	return value


func _set_speed_units(value : String) -> void:
	speed_units = value
	_update_units_label(speed_units)


func _update_units_label(value : Variant) -> Variant:
	var target : Node = get_node(^"speed_units_label")
	target.text = value
	return value


