@tool
extends Node3D
class_name WE_PathLoop

@export var paths: Array[WE_Path] = []


func update():
	recenter()


func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			update_gizmos()


func get_samples() -> Array[Transform3D]:
	var samples: Array[Transform3D] = []
	for path in paths:
		samples.append_array(path.samples)
	return samples


func recenter():
	if paths.is_empty():
		return
	var avg: Vector3
	for path in paths:
		avg += path.get_center()
	global_position = avg / paths.size()
