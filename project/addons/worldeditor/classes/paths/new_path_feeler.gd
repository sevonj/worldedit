## Temporary node when adding a new path.
##
@tool
class_name NewPathFeeler extends Node3D

var _junction: WEPathJunction  ## Junction to connect the start to.


## If this path is supposed to be immediately connected to a junction, pass it here.
func _init(junction: WEPathJunction = null):
	_junction = junction


func _ready():
	# Set selection (Editor check because unit tests don't run in editor).
	if Engine.is_editor_hint():
		var selection := EditorInterface.get_selection()
		selection.clear()
		selection.add_node(self)


func _process(_delta):
	if not _is_selected():
		_cancel()

	if _get_input_cancel():
		_cancel()

	if _get_input_commit():
		_commit()

	update_gizmos()


# --- Private --- #
func _cancel():
	queue_free()


# Instance a new path and delete self
# Path is returned for unit testing
func _commit() -> WEPath:
	# Create
	var path := WEPath.new()
	get_parent().add_child(path)
	path.global_position = global_position
	path.owner = get_tree().edited_scene_root

	# Connect
	if is_instance_valid(_junction):
		path.connect_path(_junction, WEPath.PATH_START)

	# Select (Editor check because unit tests don't run in editor).
	if Engine.is_editor_hint():
		var selection := EditorInterface.get_selection()
		selection.clear()
		selection.add_node(path)

	# Clean up self
	queue_free()

	return path


func _get_input_cancel() -> bool:
	if Input.is_action_just_pressed("ui_cancel"):
		return true
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		return true
	return false


func _get_input_commit() -> bool:
	if false:  # Cursor not in viewport
		return false
	if Input.is_action_just_pressed("ui_accept"):
		return true
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return true
	return false


# Is this node currenctly selected?
func _is_selected() -> bool:
	if Engine.is_editor_hint():
		for node in EditorInterface.get_selection().get_selected_nodes():
			if node == self:
				return true
	return false
