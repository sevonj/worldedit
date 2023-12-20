extends EditorNode3DGizmo

const CONNECT_HANDLE_OFFSET := Vector3.BACK * .5

enum HandleIdx {
	CONNECT_0,  # Drag this onto a juntion (start)
	CONNECT_1,  # Drag this onto a juntion (end)
}

# Track the handle position as they're dragged.
var connect_0_pos := Vector3.ZERO
var connect_1_pos := Vector3.ZERO

var dragging := false
# The collider which is being hovered by the currently dragged handle. Or null.
var hovered_collider


func _get_handle_name(id, secondary):
	match id:
		HandleIdx.CONNECT_0:
			return "Path Connection 0"
		HandleIdx.CONNECT_1:
			return "Path Connection 1"


func _redraw():
	clear()
	var node: WE_Path = get_node_3d()
	if !dragging:
		reset_handles()
	if node.curve.point_count < 2:
		draw_icon()
	draw_connectors(node)


func draw_icon():
	add_unscaled_billboard(get_plugin().get_material("path_icon", self), WE_CONSTS.GIZMO_ICON_SIZE)


func draw_connectors(node: WE_Path):
	""" Draw handles for Connecting / Disconnecting junctions """

	var handles := PackedVector3Array()
	var handle_ids := PackedInt32Array()

	# Add CONNECT handle to start
	if node.get("connected_0") == null:
		handles.push_back(connect_0_pos)
		handle_ids.push_back(HandleIdx.CONNECT_0)

	# Add CONNECT handle to end
	if node.get("connected_1") == null:
		handles.push_back(connect_1_pos)
		handle_ids.push_back(HandleIdx.CONNECT_1)

	if handles.size() > 0:
		add_handles(handles, get_plugin().get_material("connect", self), handle_ids)


func _set_handle(handle_id, secondary, camera, screen_pos) -> void:
	var node: WE_Path = get_node_3d()
	dragging = true

	# Calculate new handle position
	var line_a: Vector3 = camera.project_ray_origin(screen_pos)
	var line_b: Vector3 = line_a + camera.project_ray_normal(screen_pos) * 4096
	var drag_pos = GizmoUtil.plane_line_intersection(line_a, line_b, node.basis.y, connect_0_pos)

	match handle_id:
		HandleIdx.CONNECT_0:
			connect_0_pos = drag_pos * node.transform
		HandleIdx.CONNECT_1:
			connect_1_pos = drag_pos * node.transform

	hovered_collider = GizmoUtil.raycast(self, camera, screen_pos)

	_redraw()


func _commit_handle(id, secondary, restore, cancel):
	var node: WE_Path = get_node_3d()
	dragging = false

	if !is_instance_valid(hovered_collider):
		reset_handles()
		_redraw()
		return

	var junction: WE_PathJunction = hovered_collider.get_parent()
	if !is_instance_valid(junction):
		return

	match id:
		HandleIdx.CONNECT_0:
			node.connect_path(junction, node.PATH_START)
		HandleIdx.CONNECT_1:
			node.connect_path(junction, node.PATH_END)

	reset_handles()
	_redraw()


func reset_handles():
	var node: WE_Path = get_node_3d()
	hovered_collider = null
	var len := node.curve.get_baked_length()
	connect_0_pos = sample_curve_start() * CONNECT_HANDLE_OFFSET
	connect_1_pos = sample_curve_end() * -CONNECT_HANDLE_OFFSET


func sample_curve_start() -> Transform3D:
	""" This extra step is needed because the curve may have less than 2 points """
	var node: WE_Path = get_node_3d()
	match node.curve.point_count:
		0:
			return Transform3D()
		1:
			var xf = Transform3D()
			xf.origin = node.curve.get_point_position(0)
			return xf
		_:
			return node.curve.sample_baked_with_rotation(0)


func sample_curve_end() -> Transform3D:
	""" This extra step is needed because the curve may have less than 2 points """
	var node: WE_Path = get_node_3d()
	match node.curve.point_count:
		0:
			return Transform3D()
		1:
			var xf = Transform3D()
			xf.origin = node.curve.get_point_position(0)
			return xf
		_:
			return node.curve.sample_baked_with_rotation(node.curve.get_baked_length())
