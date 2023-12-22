@tool
extends EditorPlugin

var gizmoplugins = [
	preload("res://addons/worldeditor/classes/paths/we_path/we_path_gizmoplugin.gd").new(),
	preload("res://addons/worldeditor/classes/paths/we_path_junction/we_path_junction_gizmoplugin.gd").new(),
	preload("res://addons/worldeditor/classes/paths/we_path_loop/we_path_loop_gizmoplugin.gd").new()
]


func _init():
	pass


func _enter_tree():
	for gizmoplugin in gizmoplugins:
		add_node_3d_gizmo_plugin(gizmoplugin)


func _exit_tree():
	for gizmoplugin in gizmoplugins:
		remove_node_3d_gizmo_plugin(gizmoplugin)
