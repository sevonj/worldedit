@tool
extends EditorPlugin

# gdlint: disable=max-line-length
var autoload_viewport := "res://addons/worldeditor/classes/autoload_viewport.gd"
var dock: WEDock
var gizmoplugins = [
	preload("res://addons/worldeditor/classes/paths/we_path/we_path_gizmoplugin.gd").new(),
	preload("res://addons/worldeditor/classes/paths/we_path_junction/we_path_junction_gizmoplugin.gd").new(),
	preload("res://addons/worldeditor/classes/paths/we_path_loop/we_path_loop_gizmoplugin.gd").new(),
	NewPathFeelerGizmoPlugin.new()
]
var inspectorplugins = [
	preload("res://addons/worldeditor/classes/paths/we_path_loop/we_path_loop_inspectorplugin.gd").new()
]

# --- Virtual Methods --- #

func _init():
	pass


func _enter_tree():
	add_autoload_singleton("ViewportMgr", autoload_viewport)
	get_editor_interface().get_selection().selection_changed.connect(_on_selection_changed)
	dock = WEDock.new()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)

	for gizmoplugin in gizmoplugins:
		add_node_3d_gizmo_plugin(gizmoplugin)
	for inspectorplugin in inspectorplugins:
		add_inspector_plugin(inspectorplugin)


func _exit_tree():
	remove_control_from_docks(dock)

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
