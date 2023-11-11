@tool
extends Node3D


const Circle := preload("res://primitives/circle.gd")


@export var max_speed := 240.0

@export var speed := 0.0 : set = _set_speed

@export var speed_units := "km/h" : set = _set_speed_units

@export var speed_limit := 240.0

@export var warning_range := 10.0

@export var warning_gradient : Gradient


@onready var _ring_gauge : Circle = $ring_gauge

@onready var _speed_label : Label3D = $speed_label

@onready var _speed_units_label : Label3D = $speed_units_label


func _set_speed(value : float) -> void:
	speed = value

	# ensure non-negativity
	var displayed_speed := maxf(0.0, speed)

	# update arc
	var arc_fraction := 0.75 * clampf(displayed_speed / max_speed, 0.0, 1.0)
	_ring_gauge.arc_fraction = arc_fraction

	# update label
	_speed_label.text = str(int(displayed_speed))

	# update warning
	var warning_intensity := (displayed_speed - speed_limit) / warning_range
	var warning_color := warning_gradient.sample(warning_intensity)
	_speed_label.modulate = warning_color


func _set_speed_units(value : String) -> void:
	speed_units = value
	_speed_units_label.text = speed_units
