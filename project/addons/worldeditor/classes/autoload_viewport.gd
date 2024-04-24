@tool
extends Node

# --- Virtual Methods --- #


# --- Public --- #
## Cursor position to world coords projected through current viewport
func get_mouse_pos_projected() -> Vector3:
	var viewport := EditorInterface.get_editor_viewport_3d(0)
	var camera := viewport.get_camera_3d()
	var screen_pos := viewport.get_mouse_position()

	# FIXME: Somehow get camera orbit center and use if for plane_origin
	var plane_distance := 20.
	var plane_origin := camera.global_position + -camera.basis.z * plane_distance

	var line_a: Vector3 = camera.project_ray_origin(screen_pos)
	var line_b: Vector3 = line_a + camera.project_ray_normal(screen_pos) * 4096
	return GizmoUtil.plane_line_intersection(line_a, line_b, -camera.basis.z, plane_origin)


##
func create_new_path() -> void:
	var junction: WEPathJunction
	var selected := EditorInterface.get_selection().get_selected_nodes()
	if selected.size() == 1:
		if selected[0] is WEPathJunction:
			junction = selected[0]

	var feeler := NewPathFeeler.new(junction)
	get_tree().edited_scene_root.add_child(feeler)
	feeler.owner = get_tree().edited_scene_root


func debug_print_camera() -> void:
	var viewport := EditorInterface.get_editor_viewport_3d(0)
	var camera := viewport.get_camera_3d()
	print(camera.position)


# --- Private --- #
func _add_to_scene(node: Node) -> void:
	if !is_instance_valid(node):
		push_error("Invalid instance!")
		return

	var parent := get_tree().edited_scene_root
	parent.add_child(node)
	node.owner = get_tree().edited_scene_root
