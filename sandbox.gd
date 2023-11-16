@tool
extends Node3D


@export var test := false :
	set(value):
		if value:
			_test_code_builder()
			pass


func _test_code_builder() -> void:
	var builder := CodeBuilder.new()

	var script := builder.create_script(&"", builder.get_object_type(&"Node"), true)

	script.create_class(&"MyClass", builder.get_object_type(&"RefCounted"), true)

	script.create_class(&"MyClass2", builder.get_object_type(&"RefCounted"), true)

	script.create_export_property(&"foo", builder.get_object_type(&"Gradient"))

	script.create_property(&"bar", GdscriptType.FLOAT, GdscriptLiteral.create(42.0))

	script.create_onready_property(&"baz", builder.get_object_type(&"Node"))

	var function := script.create_function(&"boop", [], GdscriptType.VOID)

	var function_body := function.go_to_body()

	var variable := function_body.create_variable(&"bar2", GdscriptType.FLOAT)

	function_body.create_return(GdscriptReference.create(variable))

	var code := script.get_script_code().generate_code()

	print(code)
