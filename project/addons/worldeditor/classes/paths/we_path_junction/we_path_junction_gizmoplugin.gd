extends EditorNode3DGizmoPlugin


func _init():
	create_material("main", WEConsts.COLOR_JUNCTION)


func _has_gizmo(node):
	return node is WEPathJunction


func _get_gizmo_name():
	return "WEPathJunction"


func _redraw(gizmo):
	gizmo.clear()

	# Add collision box to make this clickable
	var coll := SphereMesh.new()
	coll.radius = WEConsts.PATHJUNC_GIZMO_SIZE
	gizmo.add_collision_triangles(coll.generate_triangle_mesh())

	# Visual marker
	gizmo.add_lines(GizmoUtil.lines_marker(), get_material("main", gizmo), false)

	# Add visual box to make this visible
	#gizmo.add_mesh(colbox)
