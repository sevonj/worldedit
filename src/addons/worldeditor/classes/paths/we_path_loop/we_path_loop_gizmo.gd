extends EditorNode3DGizmo


func _redraw():
	clear()
	var node: WEPathLoop = get_node_3d()
	add_unscaled_billboard(get_plugin().get_material("icon", self), WEConsts.GIZMO_ICON_SIZE)
	draw_lines(node)


func draw_lines(node: WEPathLoop):
	""" Lines between path points and origin """
	var lines = PackedVector3Array()
	for path in node.paths:
		if path.curve.point_count == 0:
			lines.append(path.global_position)
			lines.append(Vector3.ZERO)
			continue
		for i in path.curve.point_count:
			var pathpoint_pos := path.global_position + path.curve.get_point_position(i)
			lines.append(pathpoint_pos - node.global_position)
			lines.append(Vector3.ZERO)
	if lines.size() > 0:
		add_lines(lines, get_plugin().get_material("lines", self), false)
