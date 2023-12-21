@tool
extends Path3D
class_name WE_Path

enum {
	PATH_START,
	PATH_END,
}

var connected_0: WE_PathJunction
var connected_1: WE_PathJunction


func connect_path(junction: WE_PathJunction, end: int):
	if !is_instance_valid(junction):
		push_error("Attempted to connect an invalid junction")
		return

	match end:
		PATH_START:
			connected_0 = junction
		PATH_END:
			connected_1 = junction

	junction.connect_path(self, end)
	update()


func disconnect_path(end: int):
	match end:
		PATH_START:
			if is_instance_valid(connected_0):
				connected_0.disconnect_path(self, end)
			connected_0 = null
		PATH_END:
			if is_instance_valid(connected_1):
				connected_1.disconnect_path(self, end)
			connected_1 = null
	update()


func update():
	# We do not want scale or rotation.
	transform.basis = Basis()

	if curve.point_count <= 1:
		return

	# Keep curve ends welded to junctions
	if is_instance_valid(connected_0):
		curve.set_point_position(0, connected_0.global_position - global_position)
	if is_instance_valid(connected_1):
		curve.set_point_position(
			curve.point_count - 1, connected_1.global_position - global_position
		)
