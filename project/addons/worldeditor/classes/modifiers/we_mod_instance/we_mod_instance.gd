@tool
class_name WEModInstance
extends Node

@export var scene: PackedScene:
	set = _set_scene
@export var spacing: float = 8:
	set = _set_spacing
@export var point_up := false:
	set = _set_point_up

var instances: Array[Node3D] = []
var multimesh := MultiMesh.new()
var multimeshinstance := MultiMeshInstance3D.new()


# Setters
func _set_scene(value: PackedScene):
	scene = value
	refresh()


func _set_spacing(value: float):
	spacing = value
	refresh()


func _set_point_up(value: bool):
	point_up = value
	refresh()


# Configuration
func _get_configuration_warnings():
	if !get_parent() is WEPath:
		return "Parent is not a WEPath!"


# Main
func _ready():
	var parent: WEPath = get_parent()
	if !is_instance_valid(parent):
		return
	parent.updated.connect(refresh)
	setup_multimesh()
	refresh()


func setup_multimesh():
	add_child(multimeshinstance)
	multimeshinstance.multimesh = multimesh
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = WEConsts.MDL_ARROW
	multimesh.mesh.surface_set_material(0, WEConsts.MAT_GIZMO_PRIMARYLIGHT)


func refresh():
	clear_instances()
	if scene == null:
		return
	var parent: WEPath = get_parent()
	if !is_instance_valid(parent):
		return
	var transforms := get_instance_transforms(parent, spacing)
	instance_nodes(transforms)
	update_multimesh(transforms)


func clear_instances():
	for instance in instances:
		instance.queue_free()
	instances.clear()


func instance_nodes(transforms: Array[Transform3D]):
	""" Create instances of the scene. """
	for transform in transforms:
		var instance: Node3D = scene.instantiate()
		add_child(instance)
		instance.global_transform = transform
		instance.set_meta("_edit_lock", true)
		instances.append(instance)


func update_multimesh(transforms: Array[Transform3D]):
	""" Visualize instances using multimesh """
	multimesh.visible_instance_count = -1
	multimesh.instance_count = transforms.size()
	multimesh.visible_instance_count = transforms.size()
	for i in transforms.size():
		multimesh.set_instance_transform(i, transforms[i])


func get_instance_transforms(parent: WEPath, spacing: float) -> Array[Transform3D]:
	var point_count = parent.curve.point_count
	var transforms: Array[Transform3D] = []

	if parent.curve.point_count < 2:
		transforms.append(parent.global_transform)
		return transforms

	var length := parent.curve.get_baked_length()
	var sample_count := int(length / spacing) + 2
	var actual_spacing := length / (sample_count - 1)

	for i in sample_count:
		var transform := parent.curve.sample_baked_with_rotation(actual_spacing * i)
		transform.origin += parent.global_position
		if point_up:
			var direction := Vector3(transform.basis.z.x, 0, transform.basis.z.z).normalized()
			transform = transform.looking_at(transform.origin + direction, Vector3.UP)
		transforms.append(transform)

	return transforms
