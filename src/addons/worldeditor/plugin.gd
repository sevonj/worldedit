@tool
extends EditorPlugin

# gdlint: disable=max-line-length

var gizmoplugins = [
	preload("res://addons/worldeditor/classes/paths/we_path/we_path_gizmoplugin.gd").new(),
	(
		preload(
			"res://addons/worldeditor/classes/paths/we_path_junction/we_path_junction_gizmoplugin.gd"
		)
		. new()
	),
	preload("res://addons/worldeditor/classes/paths/we_path_loop/we_path_loop_gizmoplugin.gd").new()
]
var inspectorplugins = [
	(
		preload(
			"res://addons/worldeditor/classes/paths/we_path_loop/we_path_loop_inspectorplugin.gd"
		)
		. new()
	)
]


func _init():
	pass


func _enter_tree():
	for gizmoplugin in gizmoplugins:
		add_node_3d_gizmo_plugin(gizmoplugin)
	for inspectorplugin in inspectorplugins:
		add_inspector_plugin(inspectorplugin)


func _exit_tree():
	for gizmoplugin in gizmoplugins:
		remove_node_3d_gizmo_plugin(gizmoplugin)
	for inspectorplugin in inspectorplugins:
		remove_inspector_plugin(inspectorplugin)
