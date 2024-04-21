##
@tool
class_name WEPathLoop extends Node3D

signal updated

@export var paths: Array[WEPath] = []


func _ready():
	update()


func update():
	recenter()
	updated.emit()


func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			update_gizmos()


func get_samples() -> Array[Transform3D]:
	""" Returns samples from all paths """
	var samples: Array[Transform3D] = []
	for path in paths:
		samples.append_array(path.samples)
	return samples


func get_path_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for path in paths:
		for i in path.curve.point_count:
			points.append(path.curve.get_point_position(i) + path.global_position)
	return points


func get_normal() -> Vector3:
	""" Calculate a normal vector for the loop from path curve points.
		Placeholder returns world up vector.
	"""
	#var points: Array[Transform3D] = []
	return Vector3.UP


func recenter() -> void:
	if paths.is_empty():
		return
	global_position = get_center()


func get_center() -> Vector3:
	if paths.is_empty():
		return global_position
	var vectors: Array[Vector3] = []
	for path in paths:
		vectors.append(path.get_center())
	return WEUtility.get_center(vectors)
