##
@tool
class_name WE_PathJunction extends Node3D

@export var connection_handles: Array[WE_ConnectionHandle] = []
@export var connection_paths: Array[WE_Path] = []

# --- Virtual Methods --- #


func _init():
	set_notify_transform(true)


func _ready():
	_setup_gizmo_coll()


func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			update()


# --- Public --- #


func update() -> void:
	_prune_connections()
	for path in connection_paths:
		path.update()


func connect_path(handle: WE_ConnectionHandle, path: WE_Path) -> void:
	if handle in connection_handles:
		push_error("Attempted to add a duplicate connection.")
		return
	connection_handles.append(handle)
	connection_paths.append(path)


func disconnect_path(handle: WE_ConnectionHandle) -> void:
	if not handle in connection_handles:
		return

	for i in connection_handles.size():
		if connection_handles[i] == handle:
			connection_handles.remove_at(i)
			connection_paths.remove_at(i)
			break


# --- Private --- #


## Create an Area3D, which can be picked up by gizmo raycasts.
## The collider is used to detect dragging things over this junction.
func _setup_gizmo_coll():
	var area := Area3D.new()
	var coll := CollisionShape3D.new()
	coll.shape = BoxShape3D.new()
	coll.shape.size = Vector3.ONE * WE_CONSTS.PATHJUNC_GIZMO_SIZE
	add_child(area)
	area.add_child(coll)


## Removes invalid paths from list. Entries become invalid when the path is freed.
func _prune_connections():
	var new_paths: Array[WE_Path] = []
	for path in connection_paths:
		if is_instance_valid(path):
			new_paths.append(path)
	connection_paths = new_paths
