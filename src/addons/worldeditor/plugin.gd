@tool
extends EditorPlugin

var we_path_junction_gizmo = preload("res://addons/worldeditor/classes/paths/we_path_junction/we_path_junction_gizmo.gd").new()

func _init():
	pass


func _enter_tree():
	add_node_3d_gizmo_plugin(we_path_junction_gizmo)


func _exit_tree():
	remove_node_3d_gizmo_plugin(we_path_junction_gizmo)
