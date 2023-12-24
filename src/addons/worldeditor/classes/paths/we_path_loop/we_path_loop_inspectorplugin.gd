extends EditorInspectorPlugin

const INSPECTOR_PANEL = preload("we_path_loop_inspectorpanel.tscn")


func _can_handle(object):
	return object is WE_PathLoop


func _parse_begin(object):
	var node: WE_PathLoop = object

	var inspector_panel = INSPECTOR_PANEL.instantiate()
	add_custom_control(inspector_panel)
	inspector_panel.refresh.connect(node.update)
