@tool
extends Node3D
class_name WE_PathJunction

@export var connection_handles: Array[WE_ConnectionHandle] = []
@export var connection_paths: Array[WE_Path] = []


func _init():
	set_notify_transform(true)


func _ready():
	create_gizmo_coll()


func create_gizmo_coll():
	""" Create a child area collider, which can be picked up by gizmo raycasts """
	var area := Area3D.new()
	var coll := CollisionShape3D.new()
	coll.shape = BoxShape3D.new()
	coll.shape.size = Vector3.ONE * WE_CONSTS.PATHJUNC_GIZMO_SIZE
	add_child(area)
	area.add_child(coll)


func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			update()


func update():
	return
	for handle in connection_handles:
		handle.path.update()


func connect_path(handle: WE_ConnectionHandle, path: WE_Path):
	if handle in connection_handles:
		push_error("Attempted to add a duplicate connection.")
		return

	connection_handles.append(handle)
	connection_paths.append(path)


func disconnect_path(handle: WE_ConnectionHandle):
	if not handle in connection_handles:
		return

	for i in connection_handles.size():
		if connection_handles[i] == handle:
			connection_handles.remove_at(i)
			connection_paths.remove_at(i)
			break
