@tool
class_name ScriptContext
extends ClassContext


var _script : GdscriptScript


func get_script_code() -> GdscriptScript:
	return _script


func _from_sub_scope(base : CodeContext, sub_scope : Variant) -> CodeContext:
	_script = sub_scope
	return super._from_sub_scope(base, sub_scope)
