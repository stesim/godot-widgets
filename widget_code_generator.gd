@tool
class_name WidgetCodeGenerator
extends Resource


static var GET_NODE_FUNCTION_REFERENCE := GdscriptReference.create(GdscriptFunction.create_external(&"get_node"))

static var IS_INSIDE_TREE_FUNCTION_REFERENCE := GdscriptReference.create(GdscriptFunction.create_external(&"is_inside_tree"))


var _definition : WidgetDefinition

var _generator := GdscriptBuilder.new()

var _ready_function : GdscriptFunction

var _widget_properties := {}

var _node_properties := {}

var _data_source_intermediates := {}

var _binding_dependencies := {}


static func generate(definition : WidgetDefinition) -> String:
	var generator := WidgetCodeGenerator.new()
	generator._definition = definition
	return generator._generate_code()


func _generate_code() -> String:
	_generator.is_tool = true
	if not _definition.base_class.is_empty():
		_generator.base_class = _generator.get_object_type(_definition.base_class)

	_generate_properties()
	_generate_ready_function()
	_generate_binding_update_functions()
	_generate_binding_reactivity()

	return _generator.generate_code()


func _generate_ready_function() -> void:
	_ready_function = GdscriptFunction.create(&"_ready")
	_generator.add_function(_ready_function)


func _generate_properties() -> void:
	for property in _definition.properties:
		var generated_property := GdscriptProperty.create_export(
			_generator.to_unique_symbol_name(property.name),
			_to_gdscript_type(property.type),
		)
		_generator.add_property(generated_property)
		_widget_properties[property] = generated_property


class BindingGenerationContext extends RefCounted:
	var binding : DataBinding
	var function : GdscriptFunction
	var source_outputs := {}


func _generate_binding_update_functions() -> void:
	var context := BindingGenerationContext.new()
	for binding in _definition.bindings:
		var property_path := NodePath(binding.property_path).get_as_property_path()
		var is_valid := (
			binding.source != null
			and property_path.get_subname_count() > 0
		)
		if not is_valid:
			continue

		context.binding = binding

		var node_property := _get_node_property(binding.target_path, null)
		var function_name := _generator.to_unique_symbol_name(
			"_update"
			+ (node_property.name if node_property != null else &"")
			+ "_" + binding.property_path
		)
		var function := GdscriptFunction.create(function_name, [], GdscriptType.VOID)
		_generator.add_function(function)

		context.function = function

		var output := _generate_data_source_code(context, binding.source)
		var property_reference := _create_reference_from_property_path(
			property_path,
			GdscriptReference.create(node_property) if node_property != null else null,
		)
		var assignment := GdscriptAssignment.create(property_reference, output)
		function.body.push_back(assignment)

		# call on ready to set initial values
		_ready_function.body.push_back(
			GdscriptExpressionStatement.create(
				GdscriptFunctionCall.create(GdscriptReference.create(function))
			)
		)


func _generate_data_source_code(context : BindingGenerationContext, data_source : DataSource) -> GdscriptExpression:
	if data_source in context.source_outputs:
		return context.source_outputs[data_source].expression

	var data_type := _to_gdscript_type(data_source.get_data_type())

	var output : GdscriptExpression
	if data_source is DataFieldSource:
		output = _generate_data_field_source_code(data_source)
		if output != null:
			_add_binding_dependency(context, data_source)
	if data_source is DataPropertySource:
		output = _generate_data_property_source_code(context, data_source, data_type)
	elif data_source is DataTransformExpression:
		output = _generate_data_transform_expression_code(context, data_source, data_type)
	context.source_outputs[data_source] = {
		expression = output,
		type = data_type,
	}
	return output


func _generate_data_field_source_code(data_source : DataFieldSource) -> GdscriptExpression:
	if data_source.field == null or not data_source.field in _widget_properties:
		push_error("invalid data source field")
		return null

	var generated_property : GdscriptProperty = _widget_properties[data_source.field]
	var property_reference := GdscriptReference.create(generated_property)
	return property_reference


func _generate_data_property_source_code(context : BindingGenerationContext, data_source : DataPropertySource, data_type : GdscriptType) -> GdscriptExpression:
	var property_path := NodePath(data_source.property_path).get_as_property_path()
	if property_path.get_subname_count() == 0:
		push_error("data source property path is empty")
		return null

	var node_property := _get_node_property(data_source.target_path, null)
	var property_reference := _create_reference_from_property_path(
		property_path,
		GdscriptReference.create(node_property) if node_property != null else null,
	)

	var write_to_variable := property_path.get_subname_count() > 1
	if not write_to_variable:
		return property_reference
	else:
		var variable_name := _generator.to_unique_symbol_name(property_path.get_subname(property_path.get_subname_count() - 1))
		var variable_declaration := GdscriptVariable.create(variable_name, data_type, property_reference)
		context.function.body.push_back(variable_declaration)
		var variable_reference := GdscriptReference.create(variable_declaration)
		return variable_reference


func _generate_data_transform_expression_code(context : BindingGenerationContext, data_source : DataTransformExpression, data_type : GdscriptType) -> GdscriptExpression:
	# NOTE: input expressions must be generated before the own function
	var input_expressions : Array[GdscriptExpression] = []
	for input in data_source.inputs:
		input_expressions.push_back(_generate_data_source_code(context, input))

	var function : GdscriptFunction = _data_source_intermediates.get(data_source)
	if function == null:
		var parameters : Array[GdscriptParameter] = []
		for i in data_source.inputs.size():
			var name := data_source.input_names[i]
			var type : GdscriptType = context.source_outputs[data_source.inputs[i]].type
			var parameter := GdscriptParameter.create_parameter(name, type)
			parameters.push_back(parameter)
		var function_name := _generator.to_unique_symbol_name("_" + data_source.name) if not data_source.name.is_empty() else StringName("_" + str(data_source.expression.hash()))
		function = GdscriptFunction.create(
			function_name,
			parameters,
			data_type,
			[
				GdscriptReturn.create(
					GdscriptInlineExpression.create(data_source.expression),
				)
			],
		)
		_generator.add_function(function)

	var function_call := GdscriptFunctionCall.create(
		GdscriptReference.create(function),
		input_expressions,
	)
	var variable_name := function.name.trim_prefix("_") + "_result"
	var variable_declaration := GdscriptVariable.create(variable_name, data_type, function_call)
	context.function.body.push_back(variable_declaration)
	var variable_reference := GdscriptReference.create(variable_declaration)
	return variable_reference


func _add_binding_dependency(context : BindingGenerationContext, property_source : DataFieldSource) -> void:
	var generated_property : GdscriptProperty = _widget_properties[property_source.field]

	if not generated_property in _binding_dependencies:
		_binding_dependencies[generated_property] = {}

	var property_dependents : Dictionary = _binding_dependencies[generated_property]
	property_dependents[context.binding] = context.function


func _generate_binding_reactivity() -> void:
	for property in _binding_dependencies:
		var setter : GdscriptFunction = property.setter
		if setter == null:
			_create_default_setter(property)
			setter = property.setter

		var is_inside_tree_branch := GdscriptBranch.create(
			GdscriptFunctionCall.create(IS_INSIDE_TREE_FUNCTION_REFERENCE),
			[],
		)
		setter.body.push_back(is_inside_tree_branch)

		var property_dependents : Dictionary = _binding_dependencies[property]
		for binding in property_dependents:
			var function : GdscriptFunction = property_dependents[binding]
			var function_call := GdscriptExpressionStatement.create(
				GdscriptFunctionCall.create(GdscriptReference.create(function))
			)
			is_inside_tree_branch.then_statements.push_back(function_call)


func _create_default_setter(property : GdscriptProperty) -> void:
	if property.setter == null:
		var parameter := GdscriptParameter.create_parameter(&"value", property.type)
		property.setter = GdscriptFunction.create(
			_generator.to_unique_symbol_name(&"_set_" + property.name),
			[parameter],
			GdscriptType.VOID,
			[GdscriptAssignment.create(GdscriptReference.create(property), GdscriptReference.create(parameter))],
		)
		_generator.add_function(property.setter)


func _get_node_property(path : NodePath, type : GdscriptType) -> GdscriptProperty:
	if path.get_name_count() == 0:
		return null
	var property : GdscriptProperty = _node_properties.get(path)
	if property == null:
		var name := _generator.to_unique_symbol_name("_" + path.get_name(path.get_name_count() - 1))
		property = GdscriptProperty.create_onready(
			name,
			type,
			GdscriptFunctionCall.create(
				GET_NODE_FUNCTION_REFERENCE,
				[GdscriptLiteral.create(path)],
			),
		)
		_generator.add_property(property)
		_node_properties[path] = property
	return property


func _create_reference_from_property_path(path : NodePath, object : GdscriptExpression = null) -> GdscriptReference:
	var property_reference := object
	for i in path.get_subname_count():
		property_reference = GdscriptReference.create(
			GdscriptSymbol.create_external_symbol(path.get_subname(i)),
			property_reference,
		)
	return property_reference


func _to_gdscript_type(type : DataType) -> GdscriptType:
	# TODO: use caching for all types
	match type.base:
		DataType.Base.OBJECT:
			return _generator.get_object_type(type.specialization)
		_:
			return GdscriptType.create(int(type.base), type.specialization)
