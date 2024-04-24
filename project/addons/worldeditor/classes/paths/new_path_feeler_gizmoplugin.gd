class_name NewPathFeelerGizmoPlugin extends EditorNode3DGizmoPlugin


func _init():
	create_material("main", Color.BLUE)


func _has_gizmo(node):
	return node is NewPathFeeler


func _get_gizmo_name():
	return "NewPathFeeler"


func _redraw(gizmo):
	gizmo.clear()
	var node: NewPathFeeler = gizmo.get_node_3d()
	node.position = ViewportMgr.get_mouse_pos_projected()

	# Visual marker
	gizmo.add_lines(GizmoUtil.lines_marker(), get_material("main", gizmo), false)

	# Line between node and starting junction
	if is_instance_valid(node._junction):
		var line := PackedVector3Array([
			node._junction.global_position - node.global_position,
			Vector3.ZERO
		])
		gizmo.add_lines(line, get_material("main", gizmo), false)
