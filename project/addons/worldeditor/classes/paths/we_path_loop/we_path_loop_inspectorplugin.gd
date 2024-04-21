extends EditorInspectorPlugin

const INSPECTOR_PANEL = preload("we_path_loop_inspectorpanel.tscn")


func _can_handle(object):
	return object is WEPathLoop


func _parse_begin(object):
	var node: WEPathLoop = object

	var inspector_panel = INSPECTOR_PANEL.instantiate()
	add_custom_control(inspector_panel)
	inspector_panel.refresh.connect(node.update)
