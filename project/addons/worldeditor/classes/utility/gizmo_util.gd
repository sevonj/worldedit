class_name GizmoUtil


static func plane_line_intersection(
	line_a: Vector3, line_b: Vector3, plane_normal: Vector3, plane_point: Vector3
) -> Vector3:
	var dir := line_a - line_b
	var denominator := plane_normal.dot(dir)
	if abs(denominator) > 0.0001:
		var t := plane_normal.dot(plane_point - line_a) / denominator
		var intersect_point := line_a + t * dir
		return intersect_point
	push_error("Plane-line intersection failed")
	return Vector3.ZERO


## For checking if a handle hovers over something.
static func raycast(gizmo: Node3DGizmo, camera: Camera3D, screen_pos: Vector2) -> CollisionObject3D:
	var line_a: Vector3 = camera.project_ray_origin(screen_pos)
	var line_b: Vector3 = line_a + camera.project_ray_normal(screen_pos) * 4096
	var query := PhysicsRayQueryParameters3D.create(line_a, line_b)
	query.collide_with_areas = true
	var result = (
		gizmo
		. get_node_3d()
		. get_tree()
		. get_root()
		. get_world_3d()
		. get_direct_space_state()
		. intersect_ray(query)
	)
	return result.get("collider")


## 3D marker cross
static func lines_marker() -> PackedVector3Array:
	return PackedVector3Array(
		[
			Vector3.UP,
			Vector3.ZERO,
			Vector3.DOWN,
			Vector3.ZERO,
			Vector3.LEFT,
			Vector3.ZERO,
			Vector3.RIGHT,
			Vector3.ZERO,
			Vector3.FORWARD,
			Vector3.ZERO,
			Vector3.BACK,
			Vector3.ZERO,
		]
	)
