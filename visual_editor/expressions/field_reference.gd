extends Label


@export var field_source : DataFieldSource :
	set(value):
		field_source = value
		text = field_source.field.name


func _init() -> void:
	add_to_group(&"visual_expressions")
