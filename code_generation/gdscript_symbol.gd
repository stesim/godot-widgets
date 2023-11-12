@tool
class_name GdscriptSymbol
extends GdscriptStatement


@export var name : StringName


@warning_ignore("shadowed_variable")
static func create_external_symbol(name : StringName) -> GdscriptSymbol:
	var statement := GdscriptSymbol.new()
	statement.name = name
	return statement


func generate_code() -> String:
	return name
