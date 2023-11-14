@tool
class_name WidgetHelpers
extends RefCounted


static func replace_children(parent : Node, new_children : Array) -> void:
	var previous_children := parent.get_children()

	# remove all current children
	for child in previous_children:
		parent.remove_child(child)

	# add all new children
	for child in new_children:
		parent.add_child(child)
		#child.owner = parent.owner

	# delete all orphans, i.e. previous children that are not among the new children
	for child in previous_children:
		if child.get_parent() == null:
			child.queue_free()


static func update_mapped_children(parent : Node, data : Array, constructor : Callable, updater : Callable) -> void:
	var previous_children := parent.get_children()
	var new_children := previous_children.slice(0, data.size())

	# remove redundant children
	for child in previous_children.slice(new_children.size()):
		parent.remove_child(child)
		child.queue_free()

	# add missing children
	if previous_children.size() < data.size():
		var first_missing_index := previous_children.size()
		new_children.resize(data.size())
		for i in new_children.size() - first_missing_index:
			var child : Node = constructor.call()
			new_children[first_missing_index + i] = child
			parent.add_child(child)

	# update children
	for i in new_children.size():
		updater.call(new_children[i], data[i], i)
