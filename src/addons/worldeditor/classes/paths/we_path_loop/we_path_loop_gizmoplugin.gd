extends EditorNode3DGizmoPlugin

const GIZMO = preload("we_path_loop_gizmo.gd")


func _init():
	create_icon_material("icon", WE_CONSTS.ICON_PATHLOOP)
	create_material("lines", Color.BISQUE)


func _has_gizmo(node):
	return node is WE_PathLoop


func _get_gizmo_name():
	return "WE_PathLoop"


func _create_gizmo(node):
	if node is WE_PathLoop:
		return GIZMO.new()
	else:
		return null
