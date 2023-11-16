@tool
class_name WidgetDefinition
extends Resource


@export var update_script := false :
	set(value):
		if value:
			_update_script()

@export var target_script : Script :
	set(value):
		target_script = value
		overwrite_target_script = false
		dry_run = true

@export var overwrite_target_script := false

@export var dry_run := true

@export var global_name := &""

@export var base_class := &"Node"

@export var is_tool := false

@export var properties : Array[DataField] = []

@export var bindings : Array[DataBinding] = []


static var _LINE_STRING := "-".repeat(80)


func _update_script() -> void:
	if dry_run:
		print(_LINE_STRING)
		print(WidgetCodeGenerator.generate(self))
		print(_LINE_STRING)
		print("This is a dry run. The script above will NOT be saved!")
		print(_LINE_STRING)
		return

	if target_script == null:
		push_error("no target script selected")
		return
	if not overwrite_target_script:
		push_error("WARNING: the target script will be overwritten! If you want to continue, confirm by setting overwrite_target_script to true and try again.")
		return

	target_script.source_code = WidgetCodeGenerator.generate(self)
	if target_script.resource_path.is_empty():
		target_script.reload(true)
	else:
		ResourceSaver.save(target_script, target_script.resource_path)
