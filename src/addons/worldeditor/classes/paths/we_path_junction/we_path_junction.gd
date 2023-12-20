@tool
extends Node3D
class_name WE_PathJunction


class Connection:
	var path: WE_Path
	var end: int


var connections: Array[Connection] = []


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


func connect_path(path: WE_Path, end: int):
	if connection_already_exists(path, end):
		push_error("Attempted to add a duplicate connection.")
		return

	var new_connection = Connection.new()
	new_connection.path = path
	new_connection.end = end

	connections.append(new_connection)


func connection_already_exists(path: WE_Path, end: int) -> bool:
	for connection in connections:
		if connection.path == path and connection.end == end:
			return true
	return false
