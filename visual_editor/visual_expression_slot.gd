class_name VisualExpressionSlot
extends Control


@export var remove_on_drag := true

@export var data_source : DataSource :
	set(value):
		if data_source != value:
			data_source = value
			_update_data_source_control()


@export_group("Control Scenes")

@export var placeholder_scene : PackedScene

@export var field_scene : PackedScene


var _data_source_control : Control = null


func _ready() -> void:
	if _data_source_control == null:
		_update_data_source_control()


func _update_data_source_control() -> void:
	if _data_source_control != null:
		remove_child(_data_source_control)
		_data_source_control.queue_free()
		_data_source_control = null

	if data_source == null:
		_data_source_control = placeholder_scene.instantiate()
	elif data_source is DataFieldSource:
		_data_source_control = field_scene.instantiate()
		_data_source_control.field_source = data_source

	add_child(_data_source_control)


func _get_drag_data(_at_position : Vector2) -> Variant:
	var data := data_source
	if data != null:
		set_drag_preview(_data_source_control.duplicate())
		if remove_on_drag:
			data_source = null

	return data


func _can_drop_data(_at_position : Vector2, data : Variant) -> bool:
	return data is DataSource


func _drop_data(_at_position : Vector2, data : Variant) -> void:
	data_source = data
