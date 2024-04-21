extends EditorNode3DGizmoPlugin

const GIZMO = preload("we_path_loop_gizmo.gd")


func _init():
	create_icon_material("icon", WEConsts.ICON_PATHLOOP)
	create_material("lines", Color.BISQUE)


func _has_gizmo(node):
	return node is WEPathLoop


func _get_gizmo_name():
	return "WEPathLoop"


func _create_gizmo(node):
	if node is WEPathLoop:
		return GIZMO.new()

	return null
