class_name WEDock extends MarginContainer

const ICON = preload("res://addons/worldeditor/assets/icons/icon_worldedit.png")

var vbox: VBoxContainer

# --- Virtual Methods --- #


func _ready():
	name = "WorldEditor"

	_ui()


# --- Private --- #

func _ui_input_add_path() -> Button:
	var button := _ui_button("Path")
	button.pressed.connect(ViewportMgr.create_new_path)
	return button


func _ui_input_debug_rebuild_ui() -> Button:
	var button := _ui_button("Rebuild menu")
	button.pressed.connect(_ui_rebuild)
	return button


func _ui_title(text: String) -> Control:
	var hbox := HBoxContainer.new()
	var title := Label.new()
	title.text = text
	var after := HSeparator.new()
	after.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(title)
	hbox.add_child(after)
	return hbox


# Button preset
func _ui_button(text: String, icon: Texture2D = null) -> Button:
	var button := Button.new()
	button.text = text
	button.icon = icon
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	return button


func _ui_rebuild():
	for child in get_children():
		child.queue_free()
	_ui()


# Build UI
func _ui():
	vbox = VBoxContainer.new()
	add_child(vbox)

	var icon := TextureRect.new()
	icon.texture = ICON
	icon.stretch_mode = TextureRect.STRETCH_KEEP
	vbox.add_child(icon)

	vbox.add_child(_ui_title("Add"))
	vbox.add_child(_ui_input_add_path())

	vbox.add_child(_ui_title("Debug"))
	vbox.add_child(_ui_input_debug_rebuild_ui())
