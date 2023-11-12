@tool
class_name GdscriptProperty
extends GdscriptVariable


@export var is_export := false

@export var is_onready := false

@export var setter : GdscriptFunction = null


@warning_ignore("shadowed_variable")
static func create_export(name : StringName, type : GdscriptType, default_value : GdscriptExpression = null) -> GdscriptProperty:
	var statement := GdscriptProperty.new()
	statement.name = name
	statement.type = type
	statement.initial_value = default_value
	statement.is_export = true
	return statement


@warning_ignore("shadowed_variable")
static func create_onready(name : StringName, type : GdscriptType, default_value : GdscriptExpression = null) -> GdscriptProperty:
	var statement := GdscriptProperty.new()
	statement.name = name
	statement.type = type
	statement.initial_value = default_value
	statement.is_onready = true
	return statement


func generate_code() -> String:
	var code := ""
	if is_onready:
		code += "@onready "
	if is_export:
		code += "@export "
	code += super.generate_code().trim_suffix("\n")
	if setter != null:
		code += " : set = " + setter.name
	return code + "\n"
