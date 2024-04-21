@tool
extends EditorPlugin

# gdlint: disable=max-line-length

var gizmoplugins = [
	preload("res://addons/worldeditor/classes/paths/we_path/we_path_gizmoplugin.gd").new(),
	preload("res://addons/worldeditor/classes/paths/we_path_junction/we_path_junction_gizmoplugin.gd").new(),
	preload("res://addons/worldeditor/classes/paths/we_path_loop/we_path_loop_gizmoplugin.gd").new(),
]
var inspectorplugins = [
	preload("res://addons/worldeditor/classes/paths/we_path_loop/we_path_loop_inspectorplugin.gd").new()
]

# --- Virtual Methods --- #

func _init():
	pass


func _enter_tree():
	get_editor_interface().get_selection().selection_changed.connect(_on_selection_changed)

	for gizmoplugin in gizmoplugins:
		add_node_3d_gizmo_plugin(gizmoplugin)
	for inspectorplugin in inspectorplugins:
		add_inspector_plugin(inspectorplugin)


func _exit_tree():
	for gizmoplugin in gizmoplugins:
		remove_node_3d_gizmo_plugin(gizmoplugin)
	for inspectorplugin in inspectorplugins:
		remove_inspector_plugin(inspectorplugin)

# --- Signal Listeners --- #

# Update all nodes when they're selected
func _on_selection_changed():
	var selection := get_editor_interface().get_selection()
	for node in selection.get_selected_nodes():
		# FIXME: I don't like this, it's pretty flaky.
		if node.has_method("update"):
			node.update
