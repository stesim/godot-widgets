extends Panel


func _can_drop_data(_at_position : Vector2, data : Variant) -> bool:
	return data is Control and data.is_in_group(&"visual_expressions") and data.get_parent() == null


func _drop_data(_at_position : Vector2, data : Variant) -> void:
	var expression : Control = data
	if expression.get_parent() == null:
		expression.queue_free()
