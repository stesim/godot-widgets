@tool
class_name BranchContext
extends CodeContext


var _branch : GdscriptBranch


func go_to_then_block() -> BlockContext:
	if _branch.then_block == null:
		return null

	return BlockContext.new()._from_sub_scope(self, _branch.then_block)


func go_to_else_block() -> BlockContext:
	if _branch.else_block == null:
		return null

	return BlockContext.new()._from_sub_scope(self, _branch.else_block)


func go_to_elif_block(branch : GdscriptBranch) -> BlockContext:
	if not branch in _branch.elif_branches:
		return null

	return BlockContext.new()._from_sub_scope(self, branch.then_block)


func _from_sub_scope(base : CodeContext, sub_scope : Variant) -> CodeContext:
	_branch = sub_scope
	return super._from_sub_scope(base, sub_scope)

