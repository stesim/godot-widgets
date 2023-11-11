@tool
class_name GdscriptReference
extends GdscriptExpression


@export var symbol : GdscriptSymbol


static func to(target : GdscriptSymbol) -> GdscriptReference:
	var ref := GdscriptReference.new()
	ref.symbol = target
	return ref


func generate_code() -> String:
	return symbol.name
