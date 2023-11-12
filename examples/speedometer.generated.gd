@tool
extends Node


@export var speed : float = 0.0 : set = _set_speed

@export var max_speed : float = 240.0 : set = _set_max_speed


@onready var _speed_label := get_node(^"speed_label")

@onready var _ring_gauge := get_node(^"ring_gauge")


func _ready():
	_update_speed_label_text()
	_update_ring_gauge_arc_fraction()


func _update_speed_label_text() -> void:
	var stringify_result : String = _stringify(speed)
	_speed_label.text = stringify_result


func _stringify(speed : float) -> String:
	return str(int(speed))


func _update_ring_gauge_arc_fraction() -> void:
	var clamp_speed_result : float = _clamp_speed(speed, max_speed)
	var to_arc_fraction_result : float = _to_arc_fraction(clamp_speed_result, max_speed)
	_ring_gauge.arc_fraction = to_arc_fraction_result


func _clamp_speed(speed : float, max_speed : float) -> float:
	return clampf(speed, 0.0, max_speed)


func _to_arc_fraction(speed : float, max_speed : float) -> float:
	return 0.75 * (speed / max_speed)


func _set_speed(value : float) -> void:
	speed = value
	if is_inside_tree():
		_update_speed_label_text()
		_update_ring_gauge_arc_fraction()


func _set_max_speed(value : float) -> void:
	max_speed = value
	if is_inside_tree():
		_update_ring_gauge_arc_fraction()


