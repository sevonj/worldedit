##
@tool
class_name WEPath extends Path3D

signal updated

enum {
	PATH_START,
	PATH_END,
}

@export var connection_handle0 := WEConnectionHandle.new(self, PATH_START)
@export var connection_handle1 := WEConnectionHandle.new(self, PATH_END)
@export var connected_0: WEPathJunction
@export var connected_1: WEPathJunction

@export var segment_length: float = 4
@export var samples: Array[Transform3D] = []

# --- Virtual Methods --- #


func _init():
	if !is_instance_valid(curve):
		curve = Curve3D.new()
		curve.add_point(Vector3.ZERO)
	curve_changed.connect(_on_curve_changed)


func _ready():
	curve.up_vector_enabled = false
	regenerate_samples()


# --- Public --- #


## This will connect this path to a junction.
## Connection is initated by this function, not the one on junction.
func connect_path(junction: WEPathJunction, end: int):
	if !is_instance_valid(junction):
		push_error("Attempted to connect an invalid instance")
		return

	# Clear previous
	disconnect_path(end)

	# Add points to curve if we don't have enough already.
	while curve.point_count < 2:
		curve.add_point(Vector3.ZERO)

	# Connect
	match end:
		PATH_START:
			connected_0 = junction
			junction.connect_path(connection_handle0, self)
		PATH_END:
			connected_1 = junction
			junction.connect_path(connection_handle1, self)

	refresh()


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
	refresh()


func refresh():
	_on_any_update()

	# We do not want scale or rotation.
	transform.basis = Basis()

	if curve.point_count == 1:
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
	if is_zero_approx(length):
		samples.append(transform)
		return

	var sample_count := int(length / segment_length) + 2
	var actual_segment_length := length / (sample_count - 1)
	for i in sample_count:
		var sample = curve.sample_baked_with_rotation(actual_segment_length * i)
		sample.origin += global_position
		samples.append(sample)

	updated.emit()


## Recenters the origin to the average of curve points.
func recenter():
	var old_origin := global_position
	var new_origin := get_center()
	#§get_child(0).global_position = new_origin
	#§return
	var delta_pos := new_origin - old_origin
	global_position = new_origin
	for i in curve.point_count:
		var old_pos = curve.get_point_position(i)
		curve.set_point_position(i, old_pos - delta_pos)


## Returns the middle of curve points
func get_center() -> Vector3:
	if curve.point_count == 0:
		return global_position

	var vectors: Array[Vector3] = []
	for i in curve.point_count:
		vectors.append(curve.get_point_position(i))
	return WEUtility.get_center(vectors) + global_position


# --- Private --- #


func _on_curve_changed():
	_on_any_update()
	regenerate_samples()


# Refresh, curve changed, etc.
func _on_any_update():
	# Self-destruct if empty curve
	if curve.point_count == 0:
		queue_free()
	elif curve.point_count == 1:
		if connected_0 != null or connected_1 != null:
			queue_free()
