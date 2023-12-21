extends EditorNode3DGizmoPlugin

const GIZMO = preload("we_path_gizmo.gd")


func _init():
	create_icon_material("path_icon", WE_CONSTS.ICON_PATH)
	create_handle_material("connect", false, WE_CONSTS.ICON_PATH_CONNECT)
	create_handle_material("disconnect", false, WE_CONSTS.ICON_PATH_DISCONNECT)


func _has_gizmo(node):
	return node is WE_Path


func _get_gizmo_name():
	return "WE_Path"


func _create_gizmo(node):
	if node is WE_Path:
		return GIZMO.new()
	else:
		return null
