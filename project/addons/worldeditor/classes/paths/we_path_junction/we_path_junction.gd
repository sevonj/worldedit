##
@tool
class_name WEPathJunction extends Node3D

@export var connection_handles: Array[WEConnectionHandle] = []
@export var connection_paths: Array[WEPath] = []

# --- Virtual Methods --- #


func _init():
	set_notify_transform(true)


func _ready():
	_setup_gizmo_coll()


func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			refresh()


# --- Public --- #


func refresh() -> void:
	_prune_connections()
	for path in connection_paths:
		path.refresh()


## Connect a path to this junction.
## If you aren't the pathd, don't call this. Call connect_path() on the path instead.
func connect_path(handle: WEConnectionHandle, path: WEPath) -> void:
	if handle in connection_handles:
		push_error("Attempted to add a duplicate connection.")
		return
	connection_handles.append(handle)
	connection_paths.append(path)


func disconnect_path(handle: WEConnectionHandle) -> void:
	if not handle in connection_handles:
		return

	for i in connection_handles.size():
		if connection_handles[i] == handle:
			connection_handles.remove_at(i)
			connection_paths.remove_at(i)
			break

	if connection_handles.is_empty():
		queue_free()


# --- Private --- #


## Create an Area3D, which can be picked up by gizmo raycasts.
## The collider is used to detect dragging things over this junction.
func _setup_gizmo_coll():
	var area := Area3D.new()
	var coll := CollisionShape3D.new()
	coll.shape = BoxShape3D.new()
	coll.shape.size = Vector3.ONE * WEConsts.PATHJUNC_GIZMO_SIZE
	add_child(area)
	area.add_child(coll)


## Removes invalid paths from list. Entries become invalid when the path is freed.
func _prune_connections():
	if connection_paths.size() != connection_handles.size():
		push_error("connection_paths.size() != connection_handles.size()")
	var new_paths: Array[WEPath] = []
	var new_handles: Array[WEConnectionHandle] = []
	for i in connection_paths.size():
		var path := connection_paths[i]
		var handle := connection_handles[i]
		if is_instance_valid(path):
			new_paths.append(path)
			new_handles.append(handle)
	connection_paths = new_paths
	connection_handles = new_handles
