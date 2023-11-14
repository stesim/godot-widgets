@tool
class_name SlotBinding
extends DataBinding


func _update_resource_name() -> void:
	super._update_resource_name()
	resource_name += " » [children]"
