##
@tool
class_name WEPathLoop extends Node3D

signal updated

@export var paths: Array[WEPath] = []

# --- Virtual Methods --- #


func _enter_tree():
	_connect_path_updates()
	refresh()


func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			update_gizmos()


# --- Public --- #


func refresh() -> void:
	_recenter()
	updated.emit()


## Get loop edge vertices.
func get_samples() -> Array[Transform3D]:
	var samples: Array[Transform3D] = []
	for path in paths:
		samples.append_array(path.samples)
	return samples


## Get loop edge curve points.
func get_path_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for path in paths:
		for i in path.curve.point_count:
			points.append(path.curve.get_point_position(i) + path.global_position)
	return points


## Calculate a normal vector from curve points.
## Placeholder, returns Vector3.UP.
func get_normal() -> Vector3:
	#var points: Array[Transform3D] = []
	return Vector3.UP


## Get center in global coords
func get_center() -> Vector3:
	if paths.is_empty():
		return global_position
	var vectors: Array[Vector3] = []
	for path in paths:
		vectors.append(path.get_center())
	return WEUtility.get_center(vectors)


## Set a new path list.
func set_paths(new_paths: Array[WEPath]) -> void:
	_disconnect_path_updates()
	paths = new_paths
	_connect_path_updates()


# --- Private --- #


func _recenter() -> void:
	if paths.is_empty():
		return
	global_position = get_center()


# Connect each paths updated signal to refresh.
func _connect_path_updates() -> void:
	for path in paths:
		if not path.updated.is_connected(refresh):
			path.updated.connect(refresh)


# Disconnect each paths updated signal to refresh.
func _disconnect_path_updates() -> void:
	for path in paths:
		if path.updated.is_connected(refresh):
			path.updated.disconnect(refresh)
