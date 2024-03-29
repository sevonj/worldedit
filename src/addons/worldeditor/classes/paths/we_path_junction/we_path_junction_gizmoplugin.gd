extends EditorNode3DGizmoPlugin


func _init():
	pass


func _has_gizmo(node):
	return node is WE_PathJunction


func _get_gizmo_name():
	return "WE_PathJunction"


func _redraw(gizmo):
	gizmo.clear()

	# Add collision box to make this clickable
	var colbox = BoxMesh.new()
	colbox.size = Vector3.ONE * WE_CONSTS.PATHJUNC_GIZMO_SIZE
	gizmo.add_collision_triangles(colbox.generate_triangle_mesh())

	# Add visual box to make this visible
	gizmo.add_mesh(colbox)
