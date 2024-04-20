extends EditorNode3DGizmoPlugin

const GIZMO = preload("we_path_gizmo.gd")


func _init():
	create_icon_material("path_icon", WEConsts.ICON_PATH)
	create_handle_material("connect", false, WEConsts.ICON_PATH_CONNECT)
	create_handle_material("disconnect", false, WEConsts.ICON_PATH_DISCONNECT)


func _has_gizmo(node):
	return node is WEPath


func _get_gizmo_name():
	return "WEPath"


func _create_gizmo(node):
	if node is WEPath:
		return GIZMO.new()

	return null
