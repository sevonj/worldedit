#
#
extends EditorNode3DGizmo

enum HandleIdx {
	CONNECT_0,  # Drag this onto a juntion (start)
	CONNECT_1,  # Drag this onto a juntion (end)
	DISCONNECT_0,  # Drag this away from a juntion (start)
	DISCONNECT_1,  # Drag this away from a juntion (end)
}
const CONNECT_HANDLE_OFFSET := Vector3.BACK

# -- Nodes
var _gizmo_created := false
var _gizmo_coll_0: Area3D
var _gizmo_coll_1: Area3D

var _dragging_0 := false
var _dragging_1 := false

# Track the handle position as they're dragged.
var _connect_0_pos := Vector3.ZERO
var _connect_1_pos := Vector3.ZERO

# The collider which is being hovered by the currently dragged handle. Or null.
var _hovered_collider: Node3D


func _get_handle_name(id, _secondary):
	match id:
		HandleIdx.CONNECT_0:
			return "Path Connection 0"
		HandleIdx.CONNECT_1:
			return "Path Connection 1"
		HandleIdx.DISCONNECT_0:
			return "Path Connection 0"
		HandleIdx.DISCONNECT_1:
			return "Path Connection 1"


func _redraw():
	clear()

	var node: WEPath = get_node_3d()
	if not (_dragging_0 or _dragging_1):
		reset_handles()
	if node.curve.point_count < 2:
		add_unscaled_billboard(
			get_plugin().get_material("path_icon", self), WEConsts.GIZMO_ICON_SIZE
		)
	_draw_connector_handles(node)
	# draw_samples(node)
	_update_gizmo_coll(node)


func _set_handle(handle_id, _secondary, camera, screen_pos) -> void:
	var node: WEPath = get_node_3d()

	# Calculate new handle position
	var line_a: Vector3 = camera.project_ray_origin(screen_pos)
	var line_b: Vector3 = line_a + camera.project_ray_normal(screen_pos) * 4096
	var drag_pos = GizmoUtil.plane_line_intersection(line_a, line_b, node.basis.y, _connect_0_pos)

	match handle_id:
		HandleIdx.CONNECT_0, HandleIdx.DISCONNECT_0:
			_connect_0_pos = drag_pos * node.transform
			_dragging_0 = true

		HandleIdx.CONNECT_1, HandleIdx.DISCONNECT_1:
			_connect_1_pos = drag_pos * node.transform
			_dragging_1 = true

	_hovered_collider = GizmoUtil.raycast(self, camera, screen_pos)
	_redraw()


func _commit_handle(id, _secondary, _restore, _cancel):
	var node: WEPath = get_node_3d()
	_dragging_0 = false
	_dragging_1 = false

	# Check which end
	var end: int
	match id:
		HandleIdx.CONNECT_0, HandleIdx.DISCONNECT_0:
			end = node.PATH_START
		HandleIdx.CONNECT_1, HandleIdx.DISCONNECT_1:
			end = node.PATH_END

	# Connect
	if is_instance_valid(_hovered_collider):
		var junction: WEPathJunction
		var parent: Node3D = _hovered_collider.get_parent()

		if parent is WEPathJunction:
			junction = parent
		elif parent is WEPath:
			# Create a new junc
			junction = WEPathJunction.new()
			parent.get_parent().add_child(junction)
			junction.owner = node.get_tree().edited_scene_root
			junction.name = "WEPathJunction"
			junction.global_position = _hovered_collider.global_position
			# Connect the other path to it
			if _hovered_collider.name == "_gizmo_coll_0":
				parent.connect_path(junction, WEPath.PATH_START)
			else:
				parent.connect_path(junction, WEPath.PATH_END)

		else:
			push_error("_commit_handle(): Unknown connect type! ", parent.get_tree_string_pretty())
			return

		node.connect_path(junction, end)

	# Disconnect
	elif id == HandleIdx.DISCONNECT_0 or id == HandleIdx.DISCONNECT_1:
		node.disconnect_path(end)
		set_end_position(node, _connect_1_pos)

	reset_handles()
	_redraw()


# --- Private --- #


# Draw handles for Connecting / Disconnecting junctions
func _draw_connector_handles(node: WEPath):
	var con_handles := PackedVector3Array()
	var con_handle_ids := PackedInt32Array()
	var dis_handles := PackedVector3Array()
	var dis_handle_ids := PackedInt32Array()

	# Add CONNECT handle to start
	if node.get("connected_0") == null:
		con_handles.push_back(_connect_0_pos)
		con_handle_ids.push_back(HandleIdx.CONNECT_0)
	else:
		dis_handles.push_back(_connect_0_pos)
		dis_handle_ids.push_back(HandleIdx.DISCONNECT_0)

	# Add CONNECT handle to end
	if node.get("connected_1") == null:
		con_handles.push_back(_connect_1_pos)
		con_handle_ids.push_back(HandleIdx.CONNECT_1)
	else:
		dis_handles.push_back(_connect_1_pos)
		dis_handle_ids.push_back(HandleIdx.DISCONNECT_1)

	if con_handles.size() > 0:
		add_handles(con_handles, get_plugin().get_material("connect", self), con_handle_ids)
	if dis_handles.size() > 0:
		add_handles(dis_handles, get_plugin().get_material("disconnect", self), dis_handle_ids)


func set_start_position(node: WEPath, pos: Vector3):
	if node.curve.point_count == 0:
		return
	node.curve.set_point_position(0, pos)


func set_end_position(node: WEPath, pos: Vector3):
	if node.curve.point_count == 0:
		return
	node.curve.set_point_position(node.curve.point_count - 1, pos)


func reset_handles():
	var node: WEPath = get_node_3d()
	_hovered_collider = null
	var len := 0.
	if node.curve.point_count >= 2:
		len = node.curve.get_baked_length()

	if node.get("connected_0") == null:
		_connect_0_pos = sample_curve_start() * CONNECT_HANDLE_OFFSET
	else:
		_connect_0_pos = sample_curve_start().origin
	if node.get("connected_1") == null:
		_connect_1_pos = sample_curve_end() * -CONNECT_HANDLE_OFFSET
	else:
		_connect_1_pos = sample_curve_end().origin


func sample_curve_start() -> Transform3D:
	""" This extra step is needed because the curve may have less than 2 points """
	var node: WEPath = get_node_3d()
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
	var node: WEPath = get_node_3d()
	match node.curve.point_count:
		0:
			return Transform3D()
		1:
			var xf = Transform3D()
			xf.origin = node.curve.get_point_position(0)
			return xf
		_:
			return node.curve.sample_baked_with_rotation(node.curve.get_baked_length())


func _debug_draw_samples(node: WEPath):
	var lines = PackedVector3Array()
	for sample in node.samples:
		lines.append(sample.origin)
		lines.append(sample.origin + Vector3.UP)

	if lines.size() > 0:
		add_lines(lines, get_plugin().get_material("connect", self), false)


# Colliders on each end of the curve, connectors can be dragged over these to connect.
func _update_gizmo_coll(node: WEPath):
	# HACK: For whatever reason redraw is called twice when opening a scene. Gizmo coll is null
	# on the second call too, despite already existing, resulting in doubles (Godot 4.2.1).
	# So we check it manually.
	if !is_instance_valid(_gizmo_coll_0) and node.get_node_or_null("_gizmo_coll_0") != null:
		return

	# Create colls if they don't exist
	_setup_gizmo_colls(node)

	# Update colliders.
	match node.curve.point_count:
		0:
			_gizmo_coll_0.collision_layer = 0  # Disable collision for both
			_gizmo_coll_1.collision_layer = 0  # Disable collision for both
		1:
			_gizmo_coll_0.collision_layer = WEConsts.COL_LAYER_GIZMO
			_gizmo_coll_0.position = node.curve.get_point_position(0)
			_gizmo_coll_1.collision_layer = 0  # Disable collision for end
		_:
			_gizmo_coll_0.collision_layer = WEConsts.COL_LAYER_GIZMO
			_gizmo_coll_0.position = node.curve.get_point_position(0)
			_gizmo_coll_1.collision_layer = WEConsts.COL_LAYER_GIZMO
			_gizmo_coll_1.position = node.curve.get_point_position(node.curve.point_count - 1)

	# Disable collider if dragging the connector handle or already connected
	if _dragging_0 or node.connected_0 != null:
		_gizmo_coll_0.collision_layer = 0
	if _dragging_1:
		_gizmo_coll_1.collision_layer = 0


# Makes sure gizmo colls exist. Does nothing if they already exist.
func _setup_gizmo_colls(node: WEPath) -> void:
	if !is_instance_valid(_gizmo_coll_0):
		_gizmo_coll_0 = _create_gizmo_coll()
		_gizmo_coll_0.name = "_gizmo_coll_0"
		node.add_child(_gizmo_coll_0)

	if !is_instance_valid(_gizmo_coll_1):
		_gizmo_coll_1 = _create_gizmo_coll()
		node.add_child(_gizmo_coll_1)
		_gizmo_coll_1.name = "_gizmo_coll_1"


func _create_gizmo_coll() -> Area3D:
	var area := Area3D.new()
	var coll := CollisionShape3D.new()
	coll.shape = BoxShape3D.new()
	coll.shape.size = Vector3.ONE * WEConsts.PATHJUNC_GIZMO_SIZE
	area.add_child(coll)
	return area
