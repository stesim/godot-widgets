@tool
class_name DataProcessorSequence
extends DataProcessor


@export var steps : Array[DataProcessor] = []


func _process(context : Node, value : Variant) -> Variant:
	var processed_value : Variant = value
	for processor in steps:
		if processor != null:
			processed_value = processor.process(context, processed_value)
		else:
			push_error("data processor sequence step is null")
	return value
