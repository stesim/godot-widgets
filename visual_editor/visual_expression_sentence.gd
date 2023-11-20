class_name VisualExpressionSentence
extends HBoxContainer


var _slots : Array[VisualExpressionSlot] = []


func get_slot_count() -> int:
	return _slots.size()


func get_slot(slot_index : int) -> VisualExpressionSlot:
	return _slots[slot_index]


func _init() -> void:
	add_to_group(&"visual_expressions")


func _ready() -> void:
	for child in get_children():
		if child is VisualExpressionSlot:
			_slots.push_back(child)

	mouse_filter = Control.MOUSE_FILTER_STOP
