@tool
extends Path3D
class_name WE_Path

enum {
	PATH_START,
	PATH_END,
}

@export var connection_handle0 := WE_ConnectionHandle.new()
@export var connection_handle1 := WE_ConnectionHandle.new()
@export var connected_0: WE_PathJunction
@export var connected_1: WE_PathJunction

@export var segment_length: float = 4
@export var samples: Array[Transform3D] = []

signal updated


func _init():
	curve_changed.connect(regenerate_samples)


func _ready():
	curve.up_vector_enabled = false
	regenerate_samples()


func connect_path(junction: WE_PathJunction, end: int):
	if !is_instance_valid(junction):
		push_error("Attempted to connect an invalid junction")
		return

	match end:
		PATH_START:
			connected_0 = junction
			junction.connect_path(connection_handle0, self)
		PATH_END:
			connected_1 = junction
			junction.connect_path(connection_handle1, self)

	update()


func disconnect_path(end: int):
	match end:
		PATH_START:
			if is_instance_valid(connected_0):
				connected_0.disconnect_path(connection_handle0)
			connected_0 = null
		PATH_END:
			if is_instance_valid(connected_1):
				connected_1.disconnect_path(connection_handle1)
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

	recenter()


func regenerate_samples():
	samples.clear()
	if curve.point_count < 2:
		return

	var length := curve.get_baked_length()
	var sample_count := int(length / segment_length) + 2
	var actual_segment_length := length / (sample_count - 1)
	for i in sample_count:
		samples.append(curve.sample_baked_with_rotation(actual_segment_length * i))

	updated.emit()


func recenter():
	""" Recenters the origin to the average of curve points. """
	var old_origin := global_position
	var new_origin := get_center()
	#§get_child(0).global_position = new_origin
	#§return
	var delta_pos := new_origin - old_origin
	global_position = new_origin
	for i in curve.point_count:
		var old_pos = curve.get_point_position(i)
		curve.set_point_position(i, old_pos - delta_pos)


func get_center() -> Vector3:
	""" Returns the average of curve points """
	if curve.point_count == 0:
		return global_position

	var min = curve.get_point_position(0)
	var max = curve.get_point_position(0)
	for i in curve.point_count:
		var pos := curve.get_point_position(i)
		min.x = min(min.x, pos.x)
		min.y = min(min.y, pos.y)
		min.z = min(min.z, pos.z)
		max.x = max(max.x, pos.x)
		max.y = max(max.y, pos.y)
		max.z = max(max.z, pos.z)
	return (min + max) / 2 + global_position
