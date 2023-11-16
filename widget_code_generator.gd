@tool
class_name WidgetCodeGenerator
extends RefCounted


var _definition : WidgetDefinition

var _code_builder := CodeBuilder.new()

var _script_context : ScriptContext

var _widget_properties := {}

var _path_references := {}

var _binding_update_functions := {}

var _binding_dependencies := {}

var _data_source_intermediates := {}


static func generate(definition : WidgetDefinition) -> String:
	var generator := WidgetCodeGenerator.new()
	generator._definition = definition
	return generator._generate_code()


func _generate_code() -> String:
	_create_script()
	_create_properties()
	_create_binding_update_functions()
	_create_property_setters()
	_create_ready_function()

	return _script_context.get_script_code().generate_code()


func _create_script() -> void:
	_script_context = _code_builder.create_script(
		_definition.global_name,
		_code_builder.get_object_type(_definition.base_class) if not _definition.base_class.is_empty() else null,
		_definition.is_tool,
	)


func _create_properties() -> void:
	for property in _definition.properties:
		var name := _script_context.to_unique_symbol_name(property.name)
		var type := _to_gdscript_type(property.type)
		var default_value := GdscriptLiteral.create(property.default_value)
		_widget_properties[property] = _script_context.create_export_property(name, type, default_value)


class BindingGenerationContext extends RefCounted:
	var binding : DataBinding
	var code_block : BlockContext
	var source_outputs := {}


func _create_binding_update_functions() -> void:
	var context := BindingGenerationContext.new()
	for binding in _definition.bindings:
		# TODO: add support for slot binding
		if binding is SlotBinding:
			continue
		if binding.source == null:
			push_error("data binding has no data source")
			continue
		if binding.property_path.is_empty():
			push_error("invalid data binding property path")
			continue

		var node_reference := _get_node_reference(binding.target_path, null)
		var function_name := _script_context.to_unique_symbol_name(
			"_update" + node_reference.symbol.name + "_" + binding.property_path
		)

		var function_context := _script_context.create_function(function_name, [], GdscriptType.VOID)
		_binding_update_functions[binding] = function_context.get_function_code()

		context.binding = binding
		context.code_block = function_context.go_to_body()
		var output := _get_data_source_code(context, binding.source)

		var combined_path := _combine_paths(binding.target_path, binding.property_path)
		var property_reference := _get_path_reference(combined_path)
		context.code_block.create_assignment(property_reference, output)


func _create_property_setters() -> void:
	for field in _binding_dependencies:
		var property : GdscriptProperty = _widget_properties[field]
		if property.setter == null:
			_create_default_setter(property)

		var is_node_ready_function := _code_builder.get_external_symbol_reference(&"is_node_ready")
		var if_is_ready_branch := GdscriptBranch.create(
			GdscriptFunctionCall.create(is_node_ready_function),
			GdscriptBlock.new(),
		)
		property.setter.body.statements.push_back(if_is_ready_branch)

		var if_is_ready_block := if_is_ready_branch.then_block

		var bindings : Array[DataBinding] = _binding_dependencies[field]
		for binding in bindings:
			var function : GdscriptFunction = _binding_update_functions[binding]
			var function_call := GdscriptExpressionStatement.create(
				GdscriptFunctionCall.create(GdscriptReference.create(function))
			)
			if_is_ready_block.statements.push_back(function_call)


func _create_ready_function() -> void:
	var ready_function := _script_context.create_function(&"_ready", [], GdscriptType.VOID)
	var body := ready_function.go_to_body()

	for binding in _definition.bindings:
		var update_function : GdscriptFunction = _binding_update_functions.get(binding)
		if update_function != null:
			body.create_function_call(GdscriptReference.create(update_function))

	_create_explicit_binding_triggers(body)


func _create_explicit_binding_triggers(code_context : BlockContext) -> void:
	for binding in _definition.bindings:
		if binding.explicit_triggers.is_empty():
			continue

		var function : GdscriptFunction = _binding_update_functions.get(binding)
		if function == null:
			continue

		var function_reference := GdscriptReference.create(function)
		for trigger in binding.explicit_triggers:
			if trigger is SignalReactivityTrigger:
				_create_signal_binding_trigger(code_context, trigger, function_reference)
			else:
				push_error("unknown reactivity trigger for binding: " + binding.name)


func _get_data_source_code(context : BindingGenerationContext, data_source : DataSource) -> GdscriptExpression:
	var source_outputs : Dictionary = context.source_outputs
	var expression : GdscriptExpression = source_outputs.get(data_source)
	if expression != null:
		return source_outputs[data_source].expression

	var data_type := _to_gdscript_type(data_source.get_data_type())
	expression = _create_data_source_code(context, data_source, data_type)
	source_outputs[data_source] = {
		expression = expression,
		type = data_type,
	}
	return expression


func _create_data_source_code(context : BindingGenerationContext, data_source : DataSource, data_type : GdscriptType) -> GdscriptExpression:
	var output : GdscriptExpression
	if data_source is DataFieldSource:
		output = _create_data_field_source_code(data_source)
		if not context.binding.ignore_implicit_triggers and output != null:
			_add_binding_field_dependency(context.binding, data_source.field)
	if data_source is DataPropertySource:
		output = _create_data_property_source_code(context, data_source, data_type)
	elif data_source is DataTransformExpression:
		output = _create_data_transform_expression_code(context, data_source, data_type)
	return output


func _create_data_field_source_code(data_source : DataFieldSource) -> GdscriptExpression:
	if data_source.field == null or not data_source.field in _widget_properties:
		push_error("invalid data source field")
		return null

	var generated_property : GdscriptProperty = _widget_properties[data_source.field]
	var property_reference := GdscriptReference.create(generated_property)
	return property_reference


func _create_data_property_source_code(context : BindingGenerationContext, data_source : DataPropertySource, data_type : GdscriptType) -> GdscriptExpression:
	var combined_path := _combine_paths(data_source.node_path, data_source.property_path)
	if combined_path.get_subname_count() == 0:
		push_error("data source property path is empty")
		return null

	var property_reference := _get_path_reference(combined_path)

	var write_to_variable := combined_path.get_subname_count() > 1
	if not write_to_variable:
		return property_reference
	else:
		var code_context := context.code_block
		var variable_name := code_context.to_unique_symbol_name(_get_last_path_subname(combined_path))
		var variable_declaration := code_context.create_variable(variable_name, data_type, property_reference)
		return GdscriptReference.create(variable_declaration)


func _create_data_transform_expression_code(context : BindingGenerationContext, data_source : DataTransformExpression, data_type : GdscriptType) -> GdscriptExpression:
	# NOTE: input expressions must be generated before the own function
	var input_expressions : Array[GdscriptExpression] = []
	for input in data_source.inputs:
		input_expressions.push_back(_get_data_source_code(context, input))

	var function_reference : GdscriptReference = _data_source_intermediates.get(data_source)
	if function_reference == null:
		var parameters : Array[GdscriptParameter] = []
		for i in data_source.inputs.size():
			var name := data_source.input_names[i]
			var input := data_source.inputs[i]
			var type : GdscriptType = context.source_outputs[input].type
			var parameter := GdscriptParameter.create_parameter(name, type)
			parameters.push_back(parameter)

		var function_name := _script_context.to_unique_symbol_name(
			"_" + data_source.name if not data_source.name.is_empty()
			else "_" + str(data_source.expression.hash())
		)

		var function_context := _script_context.create_function(function_name, parameters, data_type)
		function_context.go_to_body().create_return(
			GdscriptInlineExpression.create(data_source.expression)
		)

		function_reference = GdscriptReference.create(function_context.get_function_code())
		_data_source_intermediates[data_source] = function_reference

	var function_call := GdscriptFunctionCall.create(
		function_reference,
		input_expressions,
	)

	var code_context : BlockContext = context.code_block
	var variable_name := code_context.to_unique_symbol_name(
		function_reference.symbol.name.trim_prefix("_") + "_result"
	)
	var variable_declaration := code_context.create_variable(variable_name, data_type, function_call)
	return GdscriptReference.create(variable_declaration)


func _create_signal_binding_trigger(code_context : BlockContext, trigger : SignalReactivityTrigger, update_function : GdscriptReference) -> void:
	if trigger.signal_path.is_empty():
		push_error("reactivity trigger signal path is empty")
		return

	var signal_reference := _get_path_reference(_combine_paths(trigger.node_path, trigger.signal_path))
	var connect_symbol := _code_builder.get_external_symbol_reference(&"connect").symbol
	var connect_reference := GdscriptReference.create(connect_symbol, signal_reference)

	code_context.create_function_call(connect_reference, [update_function])


func _add_binding_field_dependency(binding : DataBinding, field : DataField) -> void:
	var property_dependents : Variant = _binding_dependencies.get(field)
	if property_dependents == null:
		_binding_dependencies[field] = [binding] as Array[DataBinding]
	elif not binding in property_dependents:
		property_dependents.push_back(binding)


func _create_default_setter(property : GdscriptProperty) -> void:
	if property.setter == null:
		var name := _script_context.to_unique_symbol_name(&"_set_" + property.name)
		var parameter := GdscriptParameter.create_parameter(&"value", property.type)
		var setter := _script_context.create_function(name, [parameter], GdscriptType.VOID)

		setter.go_to_body().create_assignment(
			GdscriptReference.create(property),
			GdscriptReference.create(parameter),
		)

		property.setter = setter.get_function_code()


func _get_node_reference(path : NodePath, type : GdscriptType) -> GdscriptReference:
	if path.get_name_count() == 0:
		return null

	var ref : GdscriptReference = _path_references.get(path)

	if ref == null:
		var name := _script_context.to_unique_symbol_name("_" + _get_last_path_name(path))
		var value := GdscriptFunctionCall.create(
			_code_builder.get_external_symbol_reference(&"get_node"),
			[GdscriptLiteral.create(path)],
		)
		var property := _script_context.create_onready_property(name, type, value)
		ref = GdscriptReference.create(property)
		_path_references[path] = ref

	return ref


func _get_path_reference(path : NodePath) -> GdscriptReference:
	var ref : GdscriptReference = _path_references.get(path)

	if ref == null:
		if path.get_subname_count() > 0:
			var parent_path := _get_parent_property_path(path)
			var property := _get_last_path_subname(path)
			ref = GdscriptReference.create(
				_code_builder.get_external_symbol(property),
				_get_path_reference(parent_path),
			)
		else:
			ref = _get_node_reference(path, null)

	return ref


func _to_gdscript_type(type : DataType) -> GdscriptType:
	if type is PrimitiveDataType:
		return _code_builder.get_primitive_type(int(type.primitive_type))
	elif type is ObjectDataType:
		return _code_builder.get_object_type(type.global_class)
	elif type is ArrayDataType:
		# NOTE: GDscript does not currently support nested typed arrays, so the
		#       inner array is declared as a generic array
		var element_type_string : StringName = (
			&"" if type.element_type == null
			else &"Array" if type.element_type is ArrayDataType
			else type.element_type.to_string_name()
		)
		return _code_builder.get_array_type(element_type_string)
	elif type is VoidDataType:
		return GdscriptType.VOID

	push_error("invalid data type")
	return null


func _get_parent_property_path(path : NodePath) -> NodePath:
	var parent_path := path.get_concatenated_names()
	for i in path.get_subname_count() - 1:
		parent_path += ":" + path.get_subname(i)
	return NodePath(parent_path)


func _combine_paths(node_path : NodePath, property_path : String) -> NodePath:
	var node_part := node_path.get_concatenated_names() if not node_path.is_empty() else &""
	return node_part + ":" + property_path


func _get_last_path_name(path : NodePath) -> StringName:
	return path.get_name(path.get_name_count() - 1)


func _get_last_path_subname(path : NodePath) -> StringName:
	return path.get_subname(path.get_subname_count() - 1)
