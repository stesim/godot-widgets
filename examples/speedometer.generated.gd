@tool
extends Node


@export var speed : float = 0.0 : set = _set_speed

@export var max_speed : float = 240.0 : set = _set_max_speed

@export var speed_units : String = "km/h" : set = _set_speed_units

@export var speed_limit : float = 50.0 : set = _set_speed_limit

@export var warning_range : float = 10.0 : set = _set_warning_range

@export var warning_gradient : Gradient = null : set = _set_warning_gradient

@export var tick_interval : float = 20.0

@export var tick_radius : float = 0.55


@onready var _speed_label := get_node(^"speed_label")

@onready var _ring_gauge := get_node(^"ring_gauge")

@onready var _speed_units_label := get_node(^"speed_units_label")


func _update_speed_label_text() -> void:
	var stringify_speed_result : String = _stringify_speed(speed)
	_speed_label.text = stringify_speed_result


func _stringify_speed(speed : float) -> String:
	return str(int(speed))


func _update_ring_gauge_arc_fraction() -> void:
	var clamp_speed_result : float = _clamp_speed(speed, max_speed)
	var to_arc_fraction_result : float = _to_arc_fraction(clamp_speed_result, max_speed)
	_ring_gauge.arc_fraction = to_arc_fraction_result


func _clamp_speed(speed : float, max_speed : float) -> float:
	return clampf(speed, 0.0, max_speed)


func _to_arc_fraction(speed : float, max_speed : float) -> float:
	return 0.75 * (speed / max_speed)


func _update_speed_units_label_text() -> void:
	_speed_units_label.text = speed_units


func _update_speed_label_modulate() -> void:
	var map_speed_to_gradient_offset_result : float = _map_speed_to_gradient_offset(speed, speed_limit, warning_range)
	var sample_gradient_result : Color = _sample_gradient(warning_gradient, map_speed_to_gradient_offset_result)
	_speed_label.modulate = sample_gradient_result


func _map_speed_to_gradient_offset(speed : float, limit : float, range : float) -> float:
	return remap(speed, limit, limit + range, 0.0, 1.0)


func _sample_gradient(gradient : Gradient, offset : float) -> Color:
	return gradient.sample(offset)


func _set_speed(value : float) -> void:
	speed = value
	if is_node_ready():
		_update_speed_label_text()
		_update_ring_gauge_arc_fraction()
		_update_speed_label_modulate()


func _set_max_speed(value : float) -> void:
	max_speed = value
	if is_node_ready():
		_update_ring_gauge_arc_fraction()


func _set_speed_units(value : String) -> void:
	speed_units = value
	if is_node_ready():
		_update_speed_units_label_text()


func _set_warning_gradient(value : Gradient) -> void:
	warning_gradient = value
	if is_node_ready():
		_update_speed_label_modulate()


func _set_speed_limit(value : float) -> void:
	speed_limit = value
	if is_node_ready():
		_update_speed_label_modulate()


func _set_warning_range(value : float) -> void:
	warning_range = value
	if is_node_ready():
		_update_speed_label_modulate()


func _ready() -> void:
	_update_speed_label_text()
	_update_ring_gauge_arc_fraction()
	_update_speed_units_label_text()
	_update_speed_label_modulate()
	warning_gradient.changed.connect(_update_speed_label_modulate)


