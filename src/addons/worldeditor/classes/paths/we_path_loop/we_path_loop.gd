@tool
extends Node3D
class_name WE_PathLoop

@export var paths: Array[WE_Path] = []

signal updated


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


func get_normal() -> Vector3:
	""" Calculate a normal vector for the loop from path curve points.
		Placeholder returns world up vector.
	"""
	#var points: Array[Transform3D] = []
	return Vector3.UP


func recenter():
	if paths.is_empty():
		return
	var avg: Vector3
	for path in paths:
		avg += path.get_center()
	global_position = avg / paths.size()
