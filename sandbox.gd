@tool
extends Node3D


@export var test_codegen := false :
	set(value):
		if value:
			#_test_codegen()
			pass


#static var NODE_TYPE := GdscriptType.create(GdscriptType.Base.OBJECT, &"Node")
#
#static var GET_NODE_FUNCTION := GdscriptFunction.create_external(&"get_node")
#
#static var SET_INDEXED_FUNCTION := GdscriptFunction.create_external(&"set_indexed")
#
#static var SYMBOL_NAME_REGEX := _create_symbol_name_regex()
#
#
#func _test_codegen() -> void:
#	var widget : Widget = $speedometer
#
#	var builder := GdscriptBuilder.new()
#	builder.is_tool = true
#	builder.inherits = &"Node3D"
#
#	for binding in widget.property_bindings:
#		var property := GdscriptProperty.new()
#		property.name = _sanitize_symbol_name(binding.name).to_snake_case()
#		property.type = GdscriptType.new()
#		@warning_ignore("int_as_enum_without_cast")
#		property.type.base = int(binding.type)
#		if binding.type == PropertyBinding.DataType.RESOURCE:
#			property.type.specific = &"Resource"
#		property.initial_value = GdscriptLiteral.create(binding.get_default_value())
#		builder.properties.push_back(property)
#
#		if binding.effect != null:
#			property.setter = _create_setter(builder, property, binding.effect)
#
#	var script := GDScript.new()
#	script.source_code = builder.generate_code()
#
#	ResourceSaver.save(script, "res://examples/speedometer.generated.gd")
#
#
#func _create_setter(builder : GdscriptBuilder, property : GdscriptProperty, effect : DataProcessor) -> GdscriptFunction:
#	var function := GdscriptFunction.new()
#	function.name = "_set_" + property.name
#	var input := GdscriptParameter.create(&"value", property.type)
#	function.parameters = [input]
#	function.return_type = GdscriptType.VOID
#	builder.functions.push_back(function)
#
#	var effect_function := _data_processor_to_code(effect, builder)
#
#	var assignment := GdscriptAssignment.create(property, GdscriptReference.to(input))
#	var effect_call := GdscriptExpressionStatement.create(
#		GdscriptFunctionCall.create(effect_function, [GdscriptReference.to(property)])
#	)
#	function.body.push_back(assignment)
#	function.body.push_back(effect_call)
#	return function
#
#
#func _data_processor_to_code(processor : DataProcessor, builder : GdscriptBuilder) -> GdscriptFunction:
#	var function := GdscriptFunction.new()
#	function.name = "_" + _sanitize_symbol_name(processor.name).to_snake_case()
#	var input := GdscriptParameter.create(&"value", GdscriptType.VARIANT)
#	function.parameters = [input]
#	function.return_type = GdscriptType.VARIANT
#	builder.functions.push_back(function)
#
#	var body := function.body
#	if processor is DataProcessorSequence:
#		var processed_value := GdscriptVariable.create(&"processed_value", input.type, GdscriptReference.to(input))
#		body.push_back(processed_value)
#		for step in processor.steps:
#			var step_function := _data_processor_to_code(step, builder)
#			body.push_back(
#				GdscriptAssignment.create(processed_value, GdscriptFunctionCall.create(step_function, [GdscriptReference.to(processed_value)]))
#			)
#		body.push_back(
#			GdscriptReturn.create(GdscriptReference.to(input))
#		)
#	elif processor is DataTransform:
#		body.push_back(
#			GdscriptReturn.create(GdscriptInlineExpression.create(processor.expression))
#		)
#	elif processor is DataWriter:
#		var target := GdscriptVariable.create(&"target", NODE_TYPE,
#			GdscriptFunctionCall.create(
#				GET_NODE_FUNCTION,
#				[GdscriptLiteral.create(processor.target_path)]
#			)
#		)
#		var assignment : GdscriptStatement
#		var property_path : String = processor.property_path
#		if property_path.contains(":"):
#			assignment = GdscriptExpressionStatement.create(
#				GdscriptFunctionCall.create(
#					SET_INDEXED_FUNCTION,
#					[GdscriptLiteral.create(property_path), GdscriptReference.to(input)],
#					GdscriptReference.to(target)
#				)
#			)
#		else:
#			assignment = GdscriptAssignment.create(
#				GdscriptProperty.create(property_path, null),
#				GdscriptReference.to(input),
#				GdscriptReference.to(target)
#			)
#		body.push_back(target)
#		body.push_back(assignment)
#		body.push_back(
#			GdscriptReturn.create(GdscriptReference.to(input))
#		)
#	else:
#		body.push_back(
#			GdscriptReturn.create(GdscriptReference.to(input))
#		)
#
#	return function
#
#
#func _sanitize_symbol_name(dirty_name : String) -> String:
#	return SYMBOL_NAME_REGEX.sub(dirty_name, "_", true)
#
#
#static func _create_symbol_name_regex() -> RegEx:
#	var regex = RegEx.new()
#	regex.compile("\\W+")
#	return regex
