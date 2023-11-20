extends VisualExpressionControl


static var _SIGNATURE_PARSE_REGEX := RegEx.create_from_string("\\?(?<name>\\w+)(:(?<type>\\w+))?")


#@onready var _evaluation_signature : HBoxContainer = $evaluation/signature


var _transform_expression : DataTransformExpression


func from_data_source(data_source : DataSource) -> void:
	_transform_expression = data_source


func get_data_source() -> DataSource:
	return _transform_expression


func _ready() -> void:
	$evaluation/detail_toggle.pressed.connect(_toggle_implementation)
	$implementation/signature.text_submitted.connect(_update_signature)


func _update_signature(template_string : String) -> void:
	_transform_expression.inputs.clear()
	_transform_expression.input_names.clear()

	print(template_string)
	for result in _SIGNATURE_PARSE_REGEX.search_all(template_string):
		var name := result.get_string("name")
		var type := result.get_string("type")

		_transform_expression.input_names.push_back(name)
		_transform_expression.inputs.push_back(null)


func _toggle_implementation() -> void:
	var implementation_node := $implementation
	implementation_node.visible = not implementation_node.visible
